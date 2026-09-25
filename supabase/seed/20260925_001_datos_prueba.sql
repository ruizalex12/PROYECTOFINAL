-- EduGestion 360 - Datos academicos ficticios
-- No crea usuarios de Supabase Auth ni contiene credenciales.
-- Ejecutar despues del modelo inicial y las politicas RLS.

begin;

insert into public.asignatura (
  codigo,
  nombre,
  descripcion,
  estado
)
values
  (
    'SFM-101',
    'Introduccion a la Formacion Ministerial',
    'Fundamentos generales de la formacion ministerial.',
    true
  ),
  (
    'SFM-102',
    'Hermeneutica Biblica',
    'Principios para la interpretacion responsable de textos biblicos.',
    true
  ),
  (
    'SFM-103',
    'Liderazgo y Servicio',
    'Formacion practica para liderazgo y servicio comunitario.',
    true
  )
on conflict (codigo) do update
set
  nombre = excluded.nombre,
  descripcion = excluded.descripcion;

insert into public.periodo_academico (
  nombre,
  fecha_inicio,
  fecha_fin,
  estado
)
values (
  'Gestion 2026',
  date '2026-02-02',
  date '2026-11-30',
  true
)
on conflict (nombre) do update
set
  fecha_inicio = excluded.fecha_inicio,
  fecha_fin = excluded.fecha_fin;

insert into public.estudiante (
  codigo,
  nombres,
  apellidos,
  ci,
  telefono,
  estado
)
values
  ('EST-E2-001', 'Ana', 'Prueba', 'CI-E2-001', '70000001', true),
  ('EST-E2-002', 'Luis', 'Demostracion', 'CI-E2-002', '70000002', true)
on conflict (ci) do update
set
  codigo = excluded.codigo,
  nombres = excluded.nombres,
  apellidos = excluded.apellidos,
  telefono = excluded.telefono;

commit;
