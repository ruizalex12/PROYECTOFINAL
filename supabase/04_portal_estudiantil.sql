-- Portal estudiantil: horarios, asistencia autónoma controlada y documentos.
-- Ejecutar después de 03_roles_y_acceso.sql.
begin;
alter table public.perfiles add column if not exists telefono text;
alter table public.perfiles add column if not exists foto_url text;
alter table public.perfiles add column if not exists carrera text default 'Ingeniería Informática';

create table if not exists public.horarios(
 id uuid primary key default gen_random_uuid(),asignacion_id uuid not null references public.asignaciones(id) on delete cascade,
 dia_semana int not null check(dia_semana between 1 and 7),hora_inicio time not null,hora_fin time not null,
 aula text,created_at timestamptz not null default now(),unique(asignacion_id,dia_semana,hora_inicio),check(hora_fin>hora_inicio));
create table if not exists public.marcaciones_asistencia(
 id uuid primary key default gen_random_uuid(),asignacion_id uuid not null references public.asignaciones(id) on delete cascade,
 estudiante_id uuid not null references public.estudiantes(id) on delete cascade,fecha date not null default current_date,
 marcada_en timestamptz not null default now(),estado text not null default 'Presente' check(estado in ('Presente','Retraso')),
 unique(asignacion_id,estudiante_id,fecha));
create table if not exists public.documentos_estudiante(
 id uuid primary key default gen_random_uuid(),estudiante_id uuid not null references public.estudiantes(id) on delete cascade,
 asignacion_id uuid references public.asignaciones(id) on delete set null,nombre text not null,ruta text not null,tipo text,
 tamano_bytes bigint not null default 0,created_at timestamptz not null default now());
alter table public.horarios enable row level security;alter table public.marcaciones_asistencia enable row level security;alter table public.documentos_estudiante enable row level security;
create policy horarios_select on public.horarios for select to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id) or estudiante_pertenece_asignacion(asignacion_id));
create policy horarios_admin on public.horarios for all to authenticated using(es_admin()) with check(es_admin());
create policy marcaciones_select on public.marcaciones_asistencia for select to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id) or estudiante_id=mi_estudiante_id());
create policy marcaciones_estudiante_insert on public.marcaciones_asistencia for insert to authenticated with check(estudiante_id=mi_estudiante_id() and estudiante_pertenece_asignacion(asignacion_id) and fecha=current_date);
create policy documentos_select on public.documentos_estudiante for select to authenticated using(es_admin() or estudiante_id=mi_estudiante_id() or (asignacion_id is not null and docente_controla_asignacion(asignacion_id)));
create policy documentos_insert on public.documentos_estudiante for insert to authenticated with check(estudiante_id=mi_estudiante_id() and (asignacion_id is null or estudiante_pertenece_asignacion(asignacion_id)));
create policy documentos_delete on public.documentos_estudiante for delete to authenticated using(es_admin() or estudiante_id=mi_estudiante_id());
create policy perfil_estudiante_update on public.perfiles for update to authenticated using(id=auth.uid() and rol='estudiante') with check(id=auth.uid() and rol='estudiante');
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('documentos-estudiantes','documentos-estudiantes',false,10485760,array['application/pdf','image/jpeg','image/png','application/vnd.openxmlformats-officedocument.wordprocessingml.document']) on conflict(id) do update set file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;
create policy storage_documentos_select on storage.objects for select to authenticated using(bucket_id='documentos-estudiantes' and (storage.foldername(name))[1]=auth.uid()::text);
create policy storage_documentos_insert on storage.objects for insert to authenticated with check(bucket_id='documentos-estudiantes' and (storage.foldername(name))[1]=auth.uid()::text);
create policy storage_documentos_delete on storage.objects for delete to authenticated using(bucket_id='documentos-estudiantes' and (storage.foldername(name))[1]=auth.uid()::text);
grant select,insert,delete on public.horarios,public.marcaciones_asistencia,public.documentos_estudiante to authenticated;
commit;
