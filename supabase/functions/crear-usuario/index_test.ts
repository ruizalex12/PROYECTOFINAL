import { handleRequest, type UsuarioGateway } from './index.ts';

const assert = (condition: unknown, message: string) => {
  if (!condition) throw new Error(message);
};
const request = (body: Record<string, unknown>) => new Request(
  'http://localhost/crear-usuario',
  {
    method: 'POST',
    headers: {
      Authorization: 'Bearer jwt-de-prueba',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  },
);
const base = {
  nombres: 'Ana',
  apellidos: 'Pérez',
  ci: 'CI-100',
  telefono: null,
  correo: 'ana@example.com',
  contrasena: 'segura123',
};

const gateway = (overrides: Partial<UsuarioGateway> = {}) => {
  const calls = {
    perfiles: [] as Record<string, unknown>[],
    docentes: [] as Record<string, unknown>[],
    eliminados: [] as string[],
  };
  const implementation: UsuarioGateway = {
    obtenerUsuario: async () => ({ data: { id: 'admin-id' }, error: null }),
    obtenerPerfil: async () => ({
      data: { rol: 'ADMINISTRADOR', estado: true },
      error: null,
    }),
    buscarPorCi: async () => ({ data: null, error: null }),
    buscarPorCorreo: async () => ({ data: null, error: null }),
    crearAuth: async () => ({ data: { id: 'nuevo-id' }, error: null }),
    eliminarAuth: async (id) => {
      calls.eliminados.push(id);
      return null;
    },
    insertarPerfil: async (row) => {
      calls.perfiles.push(row);
      return { data: row, error: null };
    },
    insertarDatosDocente: async (row) => {
      calls.docentes.push(row);
      return null;
    },
    ...overrides,
  };
  return { implementation, calls };
};

Deno.test('crea ADMINISTRADOR sin datos_docente y mapea datos personales', async () => {
  const fake = gateway();
  const response = await handleRequest(request({
    ...base,
    rol: 'ADMINISTRADOR',
    direccion: 'Calle 1',
    sexo: 'FEMENINO',
    fechaNacimiento: '1990-05-20',
  }), fake.implementation);
  assert(response.status === 201, 'Debe crear el administrador.');
  assert(fake.calls.docentes.length === 0, 'No debe crear datos_docente.');
  assert(fake.calls.perfiles[0].direccion === 'Calle 1', 'Debe mapear direccion.');
  assert(fake.calls.perfiles[0].sexo === 'FEMENINO', 'Debe mapear sexo.');
  assert(
    fake.calls.perfiles[0].fecha_nacimiento === '1990-05-20',
    'Debe mapear fecha_nacimiento.',
  );
});

Deno.test('crea DOCENTE con datos_docente', async () => {
  const fake = gateway();
  const response = await handleRequest(request({
    ...base,
    rol: 'DOCENTE',
    docente: {
      especialidad: 'Teología',
      tituloProfesional: 'Licenciado',
      gradoAcademico: 'Licenciatura',
      fechaIncorporacion: '2026-01-15',
      observaciones: 'Tiempo completo',
    },
  }), fake.implementation);
  assert(response.status === 201, 'Debe crear el docente.');
  assert(fake.calls.docentes.length === 1, 'Debe crear datos_docente.');
  assert(fake.calls.docentes[0].usuario_id === 'nuevo-id', 'Debe relacionar el UUID.');
  assert(fake.calls.docentes[0].especialidad === 'Teología', 'Debe mapear especialidad.');
});

Deno.test('rechaza sexo y rol invalidos', async () => {
  const fake = gateway();
  const sexo = await handleRequest(request({
    ...base,
    rol: 'ADMINISTRADOR',
    sexo: 'INVALIDO',
  }), fake.implementation);
  const rol = await handleRequest(
    request({ ...base, rol: 'ESTUDIANTE' }),
    fake.implementation,
  );
  assert(sexo.status === 400, 'Debe rechazar sexo inválido.');
  assert(rol.status === 400, 'Debe rechazar rol inválido.');
});

Deno.test('rechaza DOCENTE del contrato nuevo sin especialidad', async () => {
  const fake = gateway();
  const response = await handleRequest(request({
    ...base,
    rol: 'DOCENTE',
    direccion: null,
    docente: {},
  }), fake.implementation);
  const body = await response.json();
  assert(response.status === 400, 'Debe rechazar especialidad ausente.');
  assert(body.code === 'ESPECIALIDAD_REQUERIDA', 'Debe informar el código correcto.');
});

Deno.test('rechaza fechas personales y profesionales invalidas', async () => {
  const fake = gateway();
  const nacimiento = await handleRequest(request({
    ...base,
    rol: 'ADMINISTRADOR',
    fechaNacimiento: '2026-02-30',
  }), fake.implementation);
  const incorporacion = await handleRequest(request({
    ...base,
    rol: 'DOCENTE',
    docente: {
      especialidad: 'Biblia',
      fechaIncorporacion: 'fecha-invalida',
    },
  }), fake.implementation);
  assert(nacimiento.status === 400, 'Debe rechazar fechaNacimiento inválida.');
  assert(incorporacion.status === 400, 'Debe rechazar fechaIncorporacion inválida.');
});

Deno.test('mantiene temporalmente el payload DOCENTE legado', async () => {
  const fake = gateway();
  const response = await handleRequest(
    request({ ...base, rol: 'DOCENTE' }),
    fake.implementation,
  );
  assert(response.status === 201, 'El Flutter actual debe seguir funcionando.');
  assert(fake.calls.docentes.length === 1, 'Todo DOCENTE debe recibir datos_docente.');
  assert(
    fake.calls.docentes[0].especialidad === null,
    'La transición permite especialidad nula solo al contrato legado.',
  );
});

Deno.test('elimina Auth si falla perfil_usuario', async () => {
  const fake = gateway({
    insertarPerfil: async () => ({ data: null, error: { message: 'falló perfil' } }),
  });
  const response = await handleRequest(
    request({ ...base, rol: 'ADMINISTRADOR' }),
    fake.implementation,
  );
  assert(response.status === 500, 'Debe informar el fallo.');
  assert(fake.calls.eliminados[0] === 'nuevo-id', 'Debe limpiar Auth.');
});

Deno.test('elimina Auth si falla datos_docente', async () => {
  const fake = gateway({
    insertarDatosDocente: async () => ({ message: 'falló datos_docente' }),
  });
  const response = await handleRequest(request({
    ...base,
    rol: 'DOCENTE',
    docente: { especialidad: 'Biblia' },
  }), fake.implementation);
  const body = await response.json();
  assert(response.status === 500, 'Debe informar el fallo profesional.');
  assert(body.code === 'DATOS_DOCENTE_ERROR', 'Debe informar el código correcto.');
  assert(fake.calls.eliminados[0] === 'nuevo-id', 'Debe limpiar Auth y perfil en cascada.');
});
