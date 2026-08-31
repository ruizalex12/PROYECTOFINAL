-- Flujo docente-estudiante por asignación: tareas, entregas y sesiones de asistencia.
create table if not exists public.tareas(
 id uuid primary key default gen_random_uuid(),asignacion_id uuid not null references asignaciones(id) on delete cascade,
 titulo text not null,descripcion text not null default '',fecha_publicacion timestamptz not null default now(),
 fecha_limite timestamptz not null,puntaje_maximo numeric(6,2) not null default 100 check(puntaje_maximo>0),
 permite_archivo boolean not null default true,estado text not null default 'Publicada' check(estado in ('Borrador','Publicada','Cerrada')),
 created_at timestamptz not null default now());
create table if not exists public.entregas_tarea(
 id uuid primary key default gen_random_uuid(),tarea_id uuid not null references tareas(id) on delete cascade,
 estudiante_id uuid not null references estudiantes(id) on delete cascade,comentario text not null default '',
 archivo_nombre text,archivo_ruta text,entregado_en timestamptz not null default now(),nota numeric(6,2),retroalimentacion text,
 unique(tarea_id,estudiante_id));
create table if not exists public.sesiones_asistencia(
 id uuid primary key default gen_random_uuid(),asignacion_id uuid not null references asignaciones(id) on delete cascade,
 titulo text not null default 'Clase',fecha date not null default current_date,abre_en timestamptz not null default now(),
 cierra_en timestamptz not null,activa boolean not null default true,created_at timestamptz not null default now(),
 check(cierra_en>abre_en));
alter table public.marcaciones_asistencia add column if not exists sesion_id uuid references sesiones_asistencia(id) on delete cascade;
alter table public.tareas enable row level security;alter table public.entregas_tarea enable row level security;alter table public.sesiones_asistencia enable row level security;
create policy tareas_select on tareas for select to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id) or estudiante_pertenece_asignacion(asignacion_id));
create policy tareas_docente_insert on tareas for insert to authenticated with check(es_admin() or docente_controla_asignacion(asignacion_id));
create policy tareas_docente_update on tareas for update to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id)) with check(es_admin() or docente_controla_asignacion(asignacion_id));
create policy tareas_docente_delete on tareas for delete to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id));
create policy entregas_select on entregas_tarea for select to authenticated using(es_admin() or estudiante_id=mi_estudiante_id() or exists(select 1 from tareas t where t.id=tarea_id and docente_controla_asignacion(t.asignacion_id)));
create policy entregas_estudiante_insert on entregas_tarea for insert to authenticated with check(estudiante_id=mi_estudiante_id() and exists(select 1 from tareas t where t.id=tarea_id and t.estado='Publicada' and t.fecha_limite>=now() and estudiante_pertenece_asignacion(t.asignacion_id)));
create policy entregas_estudiante_update on entregas_tarea for update to authenticated using(estudiante_id=mi_estudiante_id()) with check(estudiante_id=mi_estudiante_id());
create policy entregas_docente_update on entregas_tarea for update to authenticated using(exists(select 1 from tareas t where t.id=tarea_id and docente_controla_asignacion(t.asignacion_id))) with check(exists(select 1 from tareas t where t.id=tarea_id and docente_controla_asignacion(t.asignacion_id)));
create policy sesiones_select on sesiones_asistencia for select to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id) or estudiante_pertenece_asignacion(asignacion_id));
create policy sesiones_docente_all on sesiones_asistencia for all to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id)) with check(es_admin() or docente_controla_asignacion(asignacion_id));
drop policy if exists marcaciones_estudiante_insert on marcaciones_asistencia;
create policy marcaciones_estudiante_insert on marcaciones_asistencia for insert to authenticated with check(estudiante_id=mi_estudiante_id() and estudiante_pertenece_asignacion(asignacion_id) and exists(select 1 from sesiones_asistencia s where s.id=sesion_id and s.asignacion_id=marcaciones_asistencia.asignacion_id and s.activa and now() between s.abre_en and s.cierra_en));
create unique index if not exists marcacion_sesion_estudiante_unique on marcaciones_asistencia(sesion_id,estudiante_id) where sesion_id is not null;
grant select,insert,update,delete on tareas,entregas_tarea,sesiones_asistencia to authenticated;

-- Contenido inicial verificable. Los registros se enlazan a la asignación
-- Redes III creada en 05_datos_portal_estudiante.sql.
insert into public.tareas(id,asignacion_id,titulo,descripcion,fecha_limite,puntaje_maximo,estado)
values('71000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001',
       'Diseño de una red institucional','Entregar el diagrama y una breve justificación técnica.',
       '2026-09-15 23:59:00-04',100,'Publicada')
on conflict(id) do nothing;

insert into public.sesiones_asistencia(id,asignacion_id,titulo,fecha,abre_en,cierra_en,activa)
values('72000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001',
       'Clase práctica de Redes III','2026-08-31','2026-08-31 07:00:00-04','2026-08-31 23:00:00-04',true)
on conflict(id) do nothing;
