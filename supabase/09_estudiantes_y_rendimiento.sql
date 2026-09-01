-- EduGestion 360: estudiantes adicionales y datos para rendimiento docente.
-- Ejecutar una sola vez después de 08_archivos_entregas.sql.
begin;

insert into public.estudiantes
  (id,codigo,nombres,apellidos,email,telefono,estado)
values
  ('10000000-0000-0000-0000-000000000002','EST-2026-002','María','Flores','maria.flores@seminariotarija.edu','72900002','Activo'),
  ('10000000-0000-0000-0000-000000000003','EST-2026-003','Luis','Mendoza','luis.mendoza@seminariotarija.edu','72900003','Activo')
on conflict(codigo) do update set
  nombres=excluded.nombres,
  apellidos=excluded.apellidos,
  email=excluded.email,
  telefono=excluded.telefono,
  estado=excluded.estado;

insert into public.matriculas(estudiante_id,curso_id,periodo_id,estado)
values
  ('10000000-0000-0000-0000-000000000002','50000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','Inscrito'),
  ('10000000-0000-0000-0000-000000000003','50000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','Inscrito')
on conflict do nothing;

insert into public.calificaciones(evaluacion_id,estudiante_id,nota)
values
  ('70000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000002',75),
  ('70000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002',88),
  ('70000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000003',68),
  ('70000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000003',79)
on conflict(evaluacion_id,estudiante_id) do update set nota=excluded.nota;

insert into public.asistencias(asignacion_id,estudiante_id,fecha,estado)
values
  ('60000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000002','2026-08-24','Presente'),
  ('60000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000002','2026-08-26','Ausente'),
  ('60000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000003','2026-08-24','Presente'),
  ('60000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000003','2026-08-26','Presente')
on conflict(asignacion_id,estudiante_id,fecha)
do update set estado=excluded.estado;

insert into public.entregas_tarea
  (tarea_id,estudiante_id,comentario,entregado_en,nota,retroalimentacion)
values
  ('71000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000002','Actividad entregada en aula','2026-08-30 14:00:00-04',82,'Buen trabajo'),
  ('71000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000003','Actividad entregada en aula','2026-08-30 15:00:00-04',74,'Revisar la justificación')
on conflict(tarea_id,estudiante_id) do update set
  comentario=excluded.comentario,
  nota=excluded.nota,
  retroalimentacion=excluded.retroalimentacion;

commit;
