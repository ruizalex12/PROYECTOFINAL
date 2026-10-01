import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (
  status: number,
  body: Record<string, unknown>,
) =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });

Deno.serve(async (request) => {
  // ============================================================
  // CORS
  // ============================================================
  if (request.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders,
    });
  }

  if (request.method !== 'POST') {
    return json(405, {
      message: 'Método no permitido.',
    });
  }

  // ============================================================
  // VARIABLES DE SUPABASE
  // ============================================================
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

  if (!supabaseUrl || !serviceRole) {
    console.error('Faltan variables internas de Supabase.');

    return json(500, {
      message: 'La función no está configurada correctamente.',
    });
  }

  // ============================================================
  // TOKEN DEL USUARIO QUE REALIZA LA OPERACIÓN
  // ============================================================
  const authorization = request.headers.get('Authorization');

  if (!authorization?.startsWith('Bearer ')) {
    return json(401, {
      message: 'Su sesión no es válida o ha expirado.',
    });
  }

  const token = authorization.substring('Bearer '.length).trim();

  if (!token) {
    return json(401, {
      message: 'Su sesión no es válida o ha expirado.',
    });
  }

  // ============================================================
  // CLIENTE ADMINISTRATIVO
  // service_role solamente existe dentro de esta Edge Function.
  // ============================================================
  const adminClient = createClient(
    supabaseUrl,
    serviceRole,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    },
  );

  // ============================================================
  // VALIDAR JWT / SESIÓN
  // ============================================================
  const {
    data: authData,
    error: authError,
  } = await adminClient.auth.getUser(token);

  if (authError || !authData.user) {
    console.error(
      'Error validando usuario:',
      authError?.message ?? 'Usuario no encontrado',
    );

    return json(401, {
      message: 'Su sesión no es válida o ha expirado.',
    });
  }

  // ------------------------------------------------------------
  // LOGS TEMPORALES PARA ENCONTRAR EL PROBLEMA DEL 403
  // NO se imprime contraseña, token ni service_role.
  // ------------------------------------------------------------
  console.log(
    'UID autenticado:',
    authData.user.id,
  );

  console.log(
    'Correo autenticado:',
    authData.user.email ?? 'SIN_CORREO',
  );

  // ============================================================
  // COMPROBAR QUE SEA ADMINISTRADOR ACTIVO
  // ============================================================
  const {
    data: profile,
    error: profileError,
  } = await adminClient
    .from('perfil_usuario')
    .select('id, correo, rol, estado')
    .eq('id', authData.user.id)
    .maybeSingle();

  console.log(
    'Perfil encontrado:',
    profile,
  );

  console.log(
    'Error perfil:',
    profileError?.message ?? null,
  );

  if (profileError) {
    console.error(
      'Error consultando perfil del administrador:',
      profileError,
    );

    return json(403, {
      message: 'No tiene permisos para realizar esta operación.',
    });
  }

  if (!profile) {
    console.error(
      'No existe perfil_usuario para UID:',
      authData.user.id,
    );

    return json(403, {
      message: 'No tiene permisos para realizar esta operación.',
    });
  }

  if (profile.rol !== 'ADMINISTRADOR') {
    console.error(
      'Rol no autorizado:',
      profile.rol,
    );

    return json(403, {
      message: 'No tiene permisos para realizar esta operación.',
    });
  }

  if (profile.estado !== true) {
    console.error(
      'Administrador inactivo:',
      authData.user.id,
    );

    return json(403, {
      message: 'No tiene permisos para realizar esta operación.',
    });
  }

  // ============================================================
  // LEER DATOS DEL NUEVO DOCENTE
  // ============================================================
  let payload: Record<string, unknown>;

  try {
    payload = await request.json();
  } catch (_) {
    return json(400, {
      message: 'Los datos enviados no son válidos.',
    });
  }

  const nombres =
    String(payload.nombres ?? '').trim();

  const apellidos =
    String(payload.apellidos ?? '').trim();

  const ci =
    String(payload.ci ?? '').trim();

  const telefonoRaw =
    String(payload.telefono ?? '').trim();

  const telefono =
    telefonoRaw.length > 0
      ? telefonoRaw
      : null;

  const correo =
    String(payload.correo ?? '')
      .trim()
      .toLowerCase();

  const contrasena =
    String(payload.contrasena ?? '');

  // ============================================================
  // VALIDACIONES
  // ============================================================
  const emailPattern =
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  if (!nombres) {
    return json(400, {
      message: 'Los nombres son obligatorios.',
    });
  }

  if (!apellidos) {
    return json(400, {
      message: 'Los apellidos son obligatorios.',
    });
  }

  if (!ci) {
    return json(400, {
      message: 'El CI es obligatorio.',
    });
  }

  if (!correo || !emailPattern.test(correo)) {
    return json(400, {
      message: 'El correo electrónico no es válido.',
    });
  }

  if (contrasena.length < 8) {
    return json(400, {
      message:
        'La contraseña debe tener al menos 8 caracteres.',
    });
  }

  // ============================================================
  // COMPROBAR CI DUPLICADO
  // ============================================================
  const {
    data: duplicateCi,
    error: duplicateCiError,
  } = await adminClient
    .from('perfil_usuario')
    .select('id')
    .eq('ci', ci)
    .maybeSingle();

  if (duplicateCiError) {
    console.error(
      'Error verificando CI:',
      duplicateCiError,
    );

    return json(500, {
      message:
        'No fue posible verificar los datos del docente.',
    });
  }

  if (duplicateCi) {
    return json(409, {
      code: 'CI_DUPLICADO',
      message:
        'Ya existe un docente con este CI.',
    });
  }

  // ============================================================
  // COMPROBAR CORREO DUPLICADO EN perfil_usuario
  // ============================================================
  const {
    data: duplicateProfileEmail,
    error: duplicateEmailError,
  } = await adminClient
    .from('perfil_usuario')
    .select('id')
    .eq('correo', correo)
    .maybeSingle();

  if (duplicateEmailError) {
    console.error(
      'Error verificando correo:',
      duplicateEmailError,
    );

    return json(500, {
      message:
        'No fue posible verificar los datos del docente.',
    });
  }

  if (duplicateProfileEmail) {
    return json(409, {
      code: 'CORREO_DUPLICADO',
      message:
        'Ya existe una cuenta con este correo.',
    });
  }

  // ============================================================
  // CREAR USUARIO EN SUPABASE AUTH
  // ============================================================
  const {
    data: created,
    error: createError,
  } = await adminClient.auth.admin.createUser({
    email: correo,
    password: contrasena,
    email_confirm: true,
  });

  if (createError || !created.user) {
    console.error(
      'Error creando Auth:',
      createError?.message ?? 'Usuario no creado',
    );

    const isDuplicate =
      createError?.message
        ?.toLowerCase()
        .includes('already') ||
      createError?.message
        ?.toLowerCase()
        .includes('registered') ||
      createError?.message
        ?.toLowerCase()
        .includes('exists');

    return json(
      isDuplicate ? 409 : 400,
      {
        code: isDuplicate
          ? 'CORREO_DUPLICADO'
          : 'AUTH_ERROR',

        message: isDuplicate
          ? 'Ya existe una cuenta con este correo.'
          : 'No fue posible crear la cuenta del docente.',
      },
    );
  }

  const nuevoUsuarioId = created.user.id;

  console.log(
    'Usuario Auth creado:',
    nuevoUsuarioId,
  );

  // ============================================================
  // CREAR perfil_usuario
  // ============================================================
  const {
    data: row,
    error: insertError,
  } = await adminClient
    .from('perfil_usuario')
    .insert({
      id: nuevoUsuarioId,
      correo,
      nombres,
      apellidos,
      ci,
      telefono,
      rol: 'DOCENTE',
      estado: true,
    })
    .select(
      `
        id,
        correo,
        nombres,
        apellidos,
        ci,
        telefono,
        rol,
        estado,
        fecha_registro
      `,
    )
    .single();

  // ============================================================
  // SI FALLA EL PERFIL, ELIMINAR CUENTA AUTH CREADA
  // ============================================================
  if (insertError) {
    console.error(
      'Error creando perfil_usuario:',
      insertError,
    );

    const {
      error: cleanupError,
    } = await adminClient.auth.admin.deleteUser(
      nuevoUsuarioId,
    );

    if (cleanupError) {
      console.error(
        'ERROR CRÍTICO eliminando usuario Auth:',
        cleanupError,
      );

      return json(500, {
        code: 'AUTH_CLEANUP_REQUIRED',
        message:
          'No fue posible completar el registro ni revertir la cuenta. Revise Authentication.',
      });
    }

    console.log(
      'Cuenta Auth revertida correctamente:',
      nuevoUsuarioId,
    );

    const detail = `
      ${insertError.message ?? ''}
      ${insertError.details ?? ''}
      ${insertError.hint ?? ''}
    `.toLowerCase();

    if (
      insertError.code === '23505' &&
      detail.includes('ci')
    ) {
      return json(409, {
        code: 'CI_DUPLICADO',
        message:
          'Ya existe un docente con este CI.',
      });
    }

    if (
      insertError.code === '23505' &&
      (
        detail.includes('correo') ||
        detail.includes('email')
      )
    ) {
      return json(409, {
        code: 'CORREO_DUPLICADO',
        message:
          'Ya existe una cuenta con este correo.',
      });
    }

    return json(500, {
      message:
        'No fue posible completar el registro del docente.',
    });
  }

  // ============================================================
  // ÉXITO
  // ============================================================
  console.log(
    'Docente creado correctamente:',
    nuevoUsuarioId,
  );

  return json(201, {
    docente: row,
  });
});