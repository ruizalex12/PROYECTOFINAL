import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};
const json = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

type Rol = 'ADMINISTRADOR' | 'DOCENTE';
type Sexo = 'MASCULINO' | 'FEMENINO' | 'OTRO';
type OperationError = { code?: string; message: string; details?: string | null };
type Result<T> = { data: T; error: null } | { data: null; error: OperationError };

export interface UsuarioPayload {
  nombres: string;
  apellidos: string;
  ci: string;
  telefono: string | null;
  correo: string;
  password: string;
  rol: Rol;
  direccion: string | null;
  sexo: Sexo | null;
  fechaNacimiento: string | null;
  docente: {
    especialidad: string | null;
    tituloProfesional: string | null;
    gradoAcademico: string | null;
    fechaIncorporacion: string | null;
    observaciones: string | null;
  } | null;
}

export interface UsuarioGateway {
  obtenerUsuario(token: string): Promise<Result<{ id: string }>>;
  obtenerPerfil(id: string): Promise<Result<{ rol: string; estado: boolean } | null>>;
  buscarPorCi(ci: string): Promise<Result<{ id: string } | null>>;
  buscarPorCorreo(correo: string): Promise<Result<{ id: string } | null>>;
  crearAuth(correo: string, password: string): Promise<Result<{ id: string }>>;
  eliminarAuth(id: string): Promise<OperationError | null>;
  insertarPerfil(row: Record<string, unknown>): Promise<Result<Record<string, unknown>>>;
  insertarDatosDocente(row: Record<string, unknown>): Promise<OperationError | null>;
}

const optionalText = (value: unknown) => {
  if (value === null || value === undefined) return null;
  const normalized = String(value).trim();
  return normalized || null;
};

const isValidDate = (value: string) => {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const [year, month, day] = value.split('-').map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  return date.getUTCFullYear() === year &&
    date.getUTCMonth() === month - 1 && date.getUTCDate() === day;
};

type ParseResult =
  | { payload: UsuarioPayload; response?: never }
  | { payload?: never; response: Response };

export const parsePayload = (raw: Record<string, unknown>): ParseResult => {
  const nombres = String(raw.nombres ?? '').trim();
  const apellidos = String(raw.apellidos ?? '').trim();
  const ci = String(raw.ci ?? '').trim();
  const telefono = optionalText(raw.telefono);
  const correo = String(raw.correo ?? '').trim().toLowerCase();
  // `password` conserva el contrato Flutter actual.
  const password = String(raw.contrasena ?? raw.password ?? '');
  const rol = String(raw.rol ?? '').trim().toUpperCase();
  const direccion = optionalText(raw.direccion);
  const sexoText = optionalText(raw.sexo)?.toUpperCase() ?? null;
  const fechaNacimiento = optionalText(raw.fechaNacimiento);
  const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  if (!nombres || !apellidos || !ci || !emailPattern.test(correo)) {
    return { response: json(400, { message: 'Los datos del usuario no son válidos.' }) };
  }
  if (!['ADMINISTRADOR', 'DOCENTE'].includes(rol)) {
    return { response: json(400, { message: 'El rol seleccionado no es válido.' }) };
  }
  if (password.length < 8) {
    return { response: json(400, { message: 'La contraseña debe tener al menos 8 caracteres.' }) };
  }
  if (sexoText !== null && !['MASCULINO', 'FEMENINO', 'OTRO'].includes(sexoText)) {
    return { response: json(400, { message: 'El sexo seleccionado no es válido.' }) };
  }
  if (fechaNacimiento !== null && !isValidDate(fechaNacimiento)) {
    return { response: json(400, { message: 'La fecha de nacimiento no es válida.' }) };
  }

  const rawDocente = raw.docente;
  const docenteObject = rawDocente !== null && typeof rawDocente === 'object'
    ? rawDocente as Record<string, unknown>
    : null;
  const usaContratoAmpliado = ['direccion', 'sexo', 'fechaNacimiento', 'docente']
    .some((key) => Object.prototype.hasOwnProperty.call(raw, key));
  let docente: UsuarioPayload['docente'] = null;

  if (rol === 'DOCENTE') {
    const especialidad = optionalText(docenteObject?.especialidad);
    // Transición: el payload Flutter legado no envía ningún campo ampliado.
    if (usaContratoAmpliado && !especialidad) {
      return {
        response: json(400, {
          code: 'ESPECIALIDAD_REQUERIDA',
          message: 'La especialidad es obligatoria para crear un docente.',
        }),
      };
    }
    const fechaIncorporacion = optionalText(docenteObject?.fechaIncorporacion);
    if (fechaIncorporacion !== null && !isValidDate(fechaIncorporacion)) {
      return { response: json(400, { message: 'La fecha de incorporación no es válida.' }) };
    }
    docente = {
      especialidad,
      tituloProfesional: optionalText(docenteObject?.tituloProfesional),
      gradoAcademico: optionalText(docenteObject?.gradoAcademico),
      fechaIncorporacion,
      observaciones: optionalText(docenteObject?.observaciones),
    };
  }

  return {
    payload: {
      nombres,
      apellidos,
      ci,
      telefono,
      correo,
      password,
      rol: rol as Rol,
      direccion,
      sexo: sexoText as Sexo | null,
      fechaNacimiento,
      docente,
    },
  };
};

const cleanupResponse = async (
  gateway: UsuarioGateway,
  authId: string,
  fallback: Response,
) => {
  const cleanupError = await gateway.eliminarAuth(authId);
  if (cleanupError) {
    return json(500, {
      code: 'AUTH_CLEANUP_REQUIRED',
      message: 'No fue posible completar el registro ni revertir la cuenta. Revise Authentication.',
    });
  }
  return fallback;
};

export const handleRequest = async (
  request: Request,
  gateway?: UsuarioGateway,
): Promise<Response> => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (request.method !== 'POST') return json(405, { message: 'Método no permitido.' });

  const authorization = request.headers.get('Authorization');
  if (!authorization?.startsWith('Bearer ')) {
    return json(401, { message: 'Su sesión no es válida o ha expirado.' });
  }
  const resolvedGateway = gateway ?? createSupabaseGateway();
  if (!resolvedGateway) return json(500, { message: 'La función no está configurada.' });

  const authResult = await resolvedGateway.obtenerUsuario(
    authorization.substring('Bearer '.length),
  );
  if (authResult.error || !authResult.data) {
    return json(401, { message: 'Su sesión no es válida o ha expirado.' });
  }
  const profileResult = await resolvedGateway.obtenerPerfil(authResult.data.id);
  if (profileResult.error || profileResult.data?.rol !== 'ADMINISTRADOR' || !profileResult.data.estado) {
    return json(403, { message: 'No tiene permisos para realizar esta operación.' });
  }

  let rawPayload: Record<string, unknown>;
  try {
    rawPayload = await request.json();
  } catch (_) {
    return json(400, { message: 'Los datos enviados no son válidos.' });
  }
  const parsed = parsePayload(rawPayload);
  if (parsed.response) return parsed.response;
  const payload = parsed.payload;

  const duplicateCi = await resolvedGateway.buscarPorCi(payload.ci);
  if (duplicateCi.error) return json(500, { message: 'No fue posible validar el CI.' });
  if (duplicateCi.data) {
    return json(409, { code: 'CI_DUPLICADO', message: 'Ya existe un usuario con este CI.' });
  }
  const duplicateEmail = await resolvedGateway.buscarPorCorreo(payload.correo);
  if (duplicateEmail.error) return json(500, { message: 'No fue posible validar el correo.' });
  if (duplicateEmail.data) {
    return json(409, { code: 'CORREO_DUPLICADO', message: 'Ya existe una cuenta con este correo.' });
  }

  const created = await resolvedGateway.crearAuth(payload.correo, payload.password);
  if (created.error || !created.data) {
    const isDuplicate = created.error?.message.toLowerCase().includes('already');
    return json(isDuplicate ? 409 : 400, {
      code: isDuplicate ? 'CORREO_DUPLICADO' : 'AUTH_ERROR',
      message: isDuplicate
        ? 'Ya existe una cuenta con este correo.'
        : 'No fue posible crear la cuenta del usuario.',
    });
  }

  const profileInsert = await resolvedGateway.insertarPerfil({
    id: created.data.id,
    correo: payload.correo,
    nombres: payload.nombres,
    apellidos: payload.apellidos,
    ci: payload.ci,
    telefono: payload.telefono,
    direccion: payload.direccion,
    sexo: payload.sexo,
    fecha_nacimiento: payload.fechaNacimiento,
    rol: payload.rol,
    estado: true,
  });
  if (profileInsert.error || !profileInsert.data) {
    const detail = `${profileInsert.error?.message ?? ''} ${profileInsert.error?.details ?? ''}`
      .toLowerCase();
    let failure = json(500, { message: 'No fue posible completar el registro del usuario.' });
    if (profileInsert.error?.code === '23505' && detail.includes('ci')) {
      failure = json(409, { code: 'CI_DUPLICADO', message: 'Ya existe un usuario con este CI.' });
    } else if (profileInsert.error?.code === '23505') {
      failure = json(409, {
        code: 'CORREO_DUPLICADO',
        message: 'Ya existe una cuenta con este correo.',
      });
    }
    return await cleanupResponse(resolvedGateway, created.data.id, failure);
  }

  if (payload.rol === 'DOCENTE' && payload.docente !== null) {
    const docenteError = await resolvedGateway.insertarDatosDocente({
      usuario_id: created.data.id,
      especialidad: payload.docente.especialidad,
      titulo_profesional: payload.docente.tituloProfesional,
      grado_academico: payload.docente.gradoAcademico,
      fecha_incorporacion: payload.docente.fechaIncorporacion,
      observaciones: payload.docente.observaciones,
    });
    if (docenteError) {
      return await cleanupResponse(
        resolvedGateway,
        created.data.id,
        json(500, {
          code: 'DATOS_DOCENTE_ERROR',
          message: 'No fue posible guardar los datos profesionales del docente.',
        }),
      );
    }
  }
  return json(201, { usuario: profileInsert.data });
};

const createSupabaseGateway = (): UsuarioGateway | null => {
  const url = Deno.env.get('SUPABASE_URL');
  const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !serviceRole) return null;
  const client = createClient(url, serviceRole, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  return {
    async obtenerUsuario(token) {
      const { data, error } = await client.auth.getUser(token);
      return error || !data.user
        ? { data: null, error: error ?? { message: 'Usuario no encontrado.' } }
        : { data: { id: data.user.id }, error: null };
    },
    async obtenerPerfil(id) {
      const { data, error } = await client.from('perfil_usuario')
        .select('rol,estado').eq('id', id).maybeSingle();
      return error ? { data: null, error } : { data, error: null };
    },
    async buscarPorCi(ci) {
      const { data, error } = await client.from('perfil_usuario')
        .select('id').eq('ci', ci).maybeSingle();
      return error ? { data: null, error } : { data, error: null };
    },
    async buscarPorCorreo(correo) {
      const { data, error } = await client.from('perfil_usuario')
        .select('id').eq('correo', correo).maybeSingle();
      return error ? { data: null, error } : { data, error: null };
    },
    async crearAuth(correo, password) {
      const { data, error } = await client.auth.admin.createUser({
        email: correo,
        password,
        email_confirm: true,
      });
      return error || !data.user
        ? { data: null, error: error ?? { message: 'Usuario no creado.' } }
        : { data: { id: data.user.id }, error: null };
    },
    async eliminarAuth(id) {
      const { error } = await client.auth.admin.deleteUser(id);
      return error;
    },
    async insertarPerfil(row) {
      const { data, error } = await client.from('perfil_usuario')
        .insert(row).select().single();
      return error ? { data: null, error } : { data, error: null };
    },
    async insertarDatosDocente(row) {
      const { error } = await client.from('datos_docente').insert(row);
      return error;
    },
  };
};

if (import.meta.main) Deno.serve((request) => handleRequest(request));
