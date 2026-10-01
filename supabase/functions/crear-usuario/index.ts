import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

const json = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  if (request.method !== 'POST') {
    return json(405, { message: 'Método no permitido.' });
  }

  const url = Deno.env.get('SUPABASE_URL');
  const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  const authorization = request.headers.get('Authorization');
  if (!url || !serviceRole) {
    return json(500, { message: 'La función no está configurada.' });
  }
  if (!authorization?.startsWith('Bearer ')) {
    return json(401, { message: 'Su sesión no es válida o ha expirado.' });
  }

  const adminClient = createClient(url, serviceRole, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const token = authorization.substring('Bearer '.length);
  const { data: authData, error: authError } =
    await adminClient.auth.getUser(token);
  if (authError || !authData.user) {
    return json(401, { message: 'Su sesión no es válida o ha expirado.' });
  }

  const { data: profile, error: profileError } = await adminClient
    .from('perfil_usuario')
    .select('rol,estado')
    .eq('id', authData.user.id)
    .maybeSingle();
  if (profileError || profile?.rol !== 'ADMINISTRADOR' || !profile.estado) {
    return json(403, {
      message: 'No tiene permisos para realizar esta operación.',
    });
  }

  let payload: Record<string, unknown>;
  try {
    payload = await request.json();
  } catch (_) {
    return json(400, { message: 'Los datos enviados no son válidos.' });
  }

  const nombres = String(payload.nombres ?? '').trim();
  const apellidos = String(payload.apellidos ?? '').trim();
  const ci = String(payload.ci ?? '').trim();
  const telefono = String(payload.telefono ?? '').trim() || null;
  const correo = String(payload.correo ?? '').trim().toLowerCase();
  const password = String(payload.password ?? '');
  const rol = String(payload.rol ?? '').trim().toUpperCase();
  const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  if (!nombres || !apellidos || !ci || !emailPattern.test(correo)) {
    return json(400, { message: 'Los datos del usuario no son válidos.' });
  }
  if (!['ADMINISTRADOR', 'DOCENTE'].includes(rol)) {
    return json(400, { message: 'El rol seleccionado no es válido.' });
  }
  if (password.length < 8) {
    return json(400, {
      message: 'La contraseña debe tener al menos 8 caracteres.',
    });
  }

  const { data: duplicateCi, error: ciError } = await adminClient
    .from('perfil_usuario')
    .select('id')
    .eq('ci', ci)
    .maybeSingle();
  if (ciError) {
    return json(500, { message: 'No fue posible validar el CI.' });
  }
  if (duplicateCi) {
    return json(409, {
      code: 'CI_DUPLICADO',
      message: 'Ya existe un usuario con este CI.',
    });
  }

  const { data: duplicateEmail, error: emailError } = await adminClient
    .from('perfil_usuario')
    .select('id')
    .eq('correo', correo)
    .maybeSingle();
  if (emailError) {
    return json(500, { message: 'No fue posible validar el correo.' });
  }
  if (duplicateEmail) {
    return json(409, {
      code: 'CORREO_DUPLICADO',
      message: 'Ya existe una cuenta con este correo.',
    });
  }

  const { data: created, error: createError } =
    await adminClient.auth.admin.createUser({
      email: correo,
      password,
      email_confirm: true,
    });
  if (createError || !created.user) {
    const isDuplicate = createError?.message.toLowerCase().includes('already');
    return json(isDuplicate ? 409 : 400, {
      code: isDuplicate ? 'CORREO_DUPLICADO' : 'AUTH_ERROR',
      message: isDuplicate
        ? 'Ya existe una cuenta con este correo.'
        : 'No fue posible crear la cuenta del usuario.',
    });
  }

  const { data: row, error: insertError } = await adminClient
    .from('perfil_usuario')
    .insert({
      id: created.user.id,
      correo,
      nombres,
      apellidos,
      ci,
      telefono,
      rol,
      estado: true,
    })
    .select()
    .single();

  if (insertError) {
    const { error: cleanupError } =
      await adminClient.auth.admin.deleteUser(created.user.id);
    if (cleanupError) {
      return json(500, {
        code: 'AUTH_CLEANUP_REQUIRED',
        message:
          'No fue posible completar el registro ni revertir la cuenta. Revise Authentication.',
      });
    }
    const detail =
      `${insertError.message} ${insertError.details ?? ''}`.toLowerCase();
    if (insertError.code === '23505' && detail.includes('ci')) {
      return json(409, {
        code: 'CI_DUPLICADO',
        message: 'Ya existe un usuario con este CI.',
      });
    }
    if (insertError.code === '23505') {
      return json(409, {
        code: 'CORREO_DUPLICADO',
        message: 'Ya existe una cuenta con este correo.',
      });
    }
    return json(500, {
      message: 'No fue posible completar el registro del usuario.',
    });
  }

  return json(201, { usuario: row });
});
