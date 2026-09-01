-- ============================================================================
-- EDUGESTIÓN 360 - BASE DE DATOS COMPLETA PARA SUPABASE
-- ============================================================================
-- REQUISITO PREVIO:
-- Crear en Supabase Authentication > Users los siguientes usuarios:
--   estudiante@seminariotarija.edu / Estudiante2026*
--   docente@seminariotarija.edu    / Docente2026*
--
-- EJECUCIÓN:
-- Copiar y ejecutar TODO este archivo una sola vez en Supabase > SQL Editor.
-- Incluye esquema, RLS, Storage, datos iniciales y vinculación de cuentas.
-- ============================================================================


-- ============================================================================
-- SECCIÓN 1: ESQUEMA BASE Y RLS
-- ============================================================================
-- ============================================================
-- PROYECTO FINAL 360 · ESQUEMA DE AULA
-- Ejecutar en Supabase > SQL Editor.
-- Cada usuario autenticado verá solamente sus propios registros.
-- ============================================================

create extension if not exists pgcrypto;

create table if not exists public.registros_demo (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  titulo text not null check (char_length(titulo) between 3 and 80),
  descripcion text not null default '',
  estado text not null default 'activo' check (estado in ('pendiente','activo','cerrado')),
  created_at timestamptz not null default now()
);

alter table public.registros_demo enable row level security;

drop policy if exists "registros_select_propios" on public.registros_demo;
create policy "registros_select_propios"
on public.registros_demo for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "registros_insert_propios" on public.registros_demo;
create policy "registros_insert_propios"
on public.registros_demo for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "registros_update_propios" on public.registros_demo;
create policy "registros_update_propios"
on public.registros_demo for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "registros_delete_propios" on public.registros_demo;
create policy "registros_delete_propios"
on public.registros_demo for delete
to authenticated
using (auth.uid() = user_id);

grant select, insert, update, delete on table public.registros_demo to authenticated;

-- Verificación rápida del esquema:
select table_name from information_schema.tables
where table_schema = 'public' and table_name = 'registros_demo';


-- FIN DE LA SECCIÓN 1

-- ============================================================================
-- SECCIÓN 2: GESTIÓN ACADÉMICA
-- ============================================================================
-- EduGestión 360: estructura principal de gestión académica.
create extension if not exists "pgcrypto";
create table if not exists perfiles (id uuid primary key references auth.users(id) on delete cascade,nombres text not null default '',apellidos text not null default '',rol text not null default 'administrador' check (rol in ('administrador','docente','secretaria')),activo boolean not null default true,created_at timestamptz not null default now());
create table if not exists estudiantes (id uuid primary key default gen_random_uuid(),codigo text not null unique,nombres text not null,apellidos text not null,email text unique,telefono text,fecha_nacimiento date,direccion text,estado text not null default 'Activo',created_at timestamptz not null default now());
create table if not exists docentes (id uuid primary key default gen_random_uuid(),codigo text not null unique,nombres text not null,apellidos text not null,email text unique,telefono text,especialidad text not null,grado_academico text,estado text not null default 'Activo',created_at timestamptz not null default now());
create table if not exists periodos (id uuid primary key default gen_random_uuid(),nombre text not null unique,fecha_inicio date not null,fecha_fin date not null,estado text not null default 'Planificado',created_at timestamptz not null default now(),check(fecha_fin>=fecha_inicio));
create table if not exists materias (id uuid primary key default gen_random_uuid(),codigo text not null unique,nombre text not null,descripcion text,creditos int not null default 1 check(creditos>0),horas_semanales int not null default 1 check(horas_semanales>0),created_at timestamptz not null default now());
create table if not exists cursos (id uuid primary key default gen_random_uuid(),nombre text not null,paralelo text not null,gestion text not null,cupo int not null default 30 check(cupo>0),created_at timestamptz not null default now(),unique(nombre,paralelo,gestion));
create table if not exists asignaciones (id uuid primary key default gen_random_uuid(),docente_id uuid not null references docentes(id),materia_id uuid not null references materias(id),curso_id uuid not null references cursos(id),periodo_id uuid not null references periodos(id),aula text,horario text,created_at timestamptz not null default now(),unique(materia_id,curso_id,periodo_id));
create table if not exists matriculas (id uuid primary key default gen_random_uuid(),estudiante_id uuid not null references estudiantes(id),curso_id uuid not null references cursos(id),periodo_id uuid not null references periodos(id),fecha date not null default current_date,estado text not null default 'Inscrito',created_at timestamptz not null default now(),unique(estudiante_id,periodo_id));
create table if not exists asistencias (id uuid primary key default gen_random_uuid(),asignacion_id uuid not null references asignaciones(id),estudiante_id uuid not null references estudiantes(id),fecha date not null,estado text not null check(estado in ('Presente','Ausente','Licencia','Retraso')),observacion text,created_at timestamptz not null default now(),unique(asignacion_id,estudiante_id,fecha));
create table if not exists evaluaciones (id uuid primary key default gen_random_uuid(),asignacion_id uuid not null references asignaciones(id),titulo text not null,tipo text not null,ponderacion numeric(5,2) not null check(ponderacion>0 and ponderacion<=100),fecha date not null,created_at timestamptz not null default now());
create table if not exists calificaciones (id uuid primary key default gen_random_uuid(),evaluacion_id uuid not null references evaluaciones(id),estudiante_id uuid not null references estudiantes(id),nota numeric(5,2) not null check(nota>=0 and nota<=100),observacion text,created_at timestamptz not null default now(),unique(evaluacion_id,estudiante_id));
create table if not exists pagos (id uuid primary key default gen_random_uuid(),estudiante_id uuid not null references estudiantes(id),concepto text not null,monto numeric(12,2) not null check(monto>0),fecha date not null default current_date,metodo text,estado text not null default 'Pagado',created_at timestamptz not null default now());
create table if not exists anuncios (id uuid primary key default gen_random_uuid(),titulo text not null,contenido text not null,publicado_por uuid references auth.users(id),publicado_en timestamptz not null default now(),activo boolean not null default true);
create index if not exists idx_matriculas_estudiante on matriculas(estudiante_id);create index if not exists idx_asistencias_fecha on asistencias(fecha);create index if not exists idx_calificaciones_estudiante on calificaciones(estudiante_id);create index if not exists idx_asignaciones_periodo on asignaciones(periodo_id);
alter table perfiles enable row level security;alter table estudiantes enable row level security;alter table docentes enable row level security;alter table periodos enable row level security;alter table materias enable row level security;alter table cursos enable row level security;alter table asignaciones enable row level security;alter table matriculas enable row level security;alter table asistencias enable row level security;alter table evaluaciones enable row level security;alter table calificaciones enable row level security;alter table pagos enable row level security;alter table anuncios enable row level security;
do $$ declare t text; begin foreach t in array array['perfiles','estudiantes','docentes','periodos','materias','cursos','asignaciones','matriculas','asistencias','evaluaciones','calificaciones','pagos','anuncios'] loop execute format('drop policy if exists "Acceso autenticado" on %I',t);execute format('create policy "Acceso autenticado" on %I for all to authenticated using (true) with check (true)',t);end loop;end $$;
create or replace function public.crear_perfil_usuario() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into perfiles(id,nombres,apellidos) values(new.id,coalesce(new.raw_user_meta_data->>'nombres',''),coalesce(new.raw_user_meta_data->>'apellidos','')) on conflict do nothing;return new;end;$$;
drop trigger if exists al_crear_usuario on auth.users;create trigger al_crear_usuario after insert on auth.users for each row execute procedure public.crear_perfil_usuario();
insert into periodos(nombre,fecha_inicio,fecha_fin,estado) values ('Gestión II/2026','2026-08-01','2026-12-15','Activo') on conflict do nothing;
insert into materias(codigo,nombre,creditos,horas_semanales) values ('INF-101','Programación I',5,6),('MAT-101','Matemática I',5,6),('ADM-110','Administración',4,4) on conflict do nothing;


-- FIN DE LA SECCIÓN 2

-- ============================================================================
-- SECCIÓN 3: ROLES Y ACCESO
-- ============================================================================
-- EduGestión 360 · Roles, vínculos académicos y RLS relacional
-- Depende de las secciones de esquema y gestión académica anteriores.
begin;

alter table public.perfiles add column if not exists email text;
alter table public.perfiles add column if not exists estudiante_id uuid references public.estudiantes(id) on delete set null;
alter table public.perfiles add column if not exists docente_id uuid references public.docentes(id) on delete set null;
update public.perfiles set rol='admin' where rol='administrador';
alter table public.perfiles drop constraint if exists perfiles_rol_check;
alter table public.perfiles add constraint perfiles_rol_check check (rol in ('admin','docente','estudiante'));
alter table public.perfiles alter column rol set default 'estudiante';
create unique index if not exists perfiles_estudiante_unique on public.perfiles(estudiante_id) where estudiante_id is not null;
create unique index if not exists perfiles_docente_unique on public.perfiles(docente_id) where docente_id is not null;

alter table public.anuncios add column if not exists asignacion_id uuid references public.asignaciones(id) on delete cascade;
create index if not exists idx_anuncios_asignacion on public.anuncios(asignacion_id);
alter table public.asistencias drop constraint if exists asistencias_estado_check;
alter table public.asistencias add constraint asistencias_estado_check check (estado in ('Presente','Ausente','Justificado','Retraso','Licencia'));
alter table public.matriculas drop constraint if exists matriculas_estudiante_id_periodo_id_key;
create unique index if not exists matriculas_estudiante_curso_periodo_unique on public.matriculas(estudiante_id,curso_id,periodo_id);

create or replace function public.es_admin() returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from perfiles where id=auth.uid() and rol='admin' and activo);$$;
create or replace function public.mi_docente_id() returns uuid language sql stable security definer set search_path=public as $$select docente_id from perfiles where id=auth.uid() and rol='docente' and activo;$$;
create or replace function public.mi_estudiante_id() returns uuid language sql stable security definer set search_path=public as $$select estudiante_id from perfiles where id=auth.uid() and rol='estudiante' and activo;$$;
create or replace function public.docente_controla_asignacion(p_asignacion uuid) returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from asignaciones where id=p_asignacion and docente_id=mi_docente_id());$$;
create or replace function public.estudiante_pertenece_asignacion(p_asignacion uuid,p_estudiante uuid default null) returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from asignaciones a join matriculas m on m.curso_id=a.curso_id and m.periodo_id=a.periodo_id where a.id=p_asignacion and m.estudiante_id=coalesce(p_estudiante,mi_estudiante_id()) and m.estado='Inscrito');$$;
revoke all on function public.es_admin() from public;revoke all on function public.mi_docente_id() from public;revoke all on function public.mi_estudiante_id() from public;revoke all on function public.docente_controla_asignacion(uuid) from public;revoke all on function public.estudiante_pertenece_asignacion(uuid,uuid) from public;
grant execute on function public.es_admin(),public.mi_docente_id(),public.mi_estudiante_id(),public.docente_controla_asignacion(uuid),public.estudiante_pertenece_asignacion(uuid,uuid) to authenticated;

-- Elimina la política temporal permisiva creada en 02.
do $$declare t text;begin foreach t in array array['perfiles','estudiantes','docentes','periodos','materias','cursos','asignaciones','matriculas','asistencias','evaluaciones','calificaciones','pagos','anuncios'] loop execute format('drop policy if exists "Acceso autenticado" on public.%I',t);end loop;end$$;

-- Perfiles: cada usuario se ve; solo admin administra y cambia roles.
create policy perfiles_select on public.perfiles for select to authenticated using(id=auth.uid() or es_admin());
create policy perfiles_admin_insert on public.perfiles for insert to authenticated with check(es_admin());
create policy perfiles_admin_update on public.perfiles for update to authenticated using(es_admin()) with check(es_admin());
create policy perfiles_admin_delete on public.perfiles for delete to authenticated using(es_admin());

-- Catálogos no sensibles: visibles al autenticado; escritura solo admin.
do $$declare t text;begin foreach t in array array['periodos','materias','cursos'] loop execute format('create policy %I on public.%I for select to authenticated using (true)',t||'_select',t);execute format('create policy %I on public.%I for insert to authenticated with check (es_admin())',t||'_insert_admin',t);execute format('create policy %I on public.%I for update to authenticated using (es_admin()) with check (es_admin())',t||'_update_admin',t);execute format('create policy %I on public.%I for delete to authenticated using (es_admin())',t||'_delete_admin',t);end loop;end$$;

create policy estudiantes_select on public.estudiantes for select to authenticated using(es_admin() or id=mi_estudiante_id() or exists(select 1 from matriculas m join asignaciones a on a.curso_id=m.curso_id and a.periodo_id=m.periodo_id where m.estudiante_id=estudiantes.id and a.docente_id=mi_docente_id()));
create policy estudiantes_admin_insert on public.estudiantes for insert to authenticated with check(es_admin());create policy estudiantes_admin_update on public.estudiantes for update to authenticated using(es_admin()) with check(es_admin());create policy estudiantes_admin_delete on public.estudiantes for delete to authenticated using(es_admin());
create policy docentes_select on public.docentes for select to authenticated using(es_admin() or id=mi_docente_id() or exists(select 1 from asignaciones a where a.docente_id=docentes.id and estudiante_pertenece_asignacion(a.id)));
create policy docentes_admin_insert on public.docentes for insert to authenticated with check(es_admin());create policy docentes_admin_update on public.docentes for update to authenticated using(es_admin()) with check(es_admin());create policy docentes_admin_delete on public.docentes for delete to authenticated using(es_admin());

create policy asignaciones_select on public.asignaciones for select to authenticated using(es_admin() or docente_id=mi_docente_id() or estudiante_pertenece_asignacion(id));
create policy asignaciones_admin_insert on public.asignaciones for insert to authenticated with check(es_admin());create policy asignaciones_admin_update on public.asignaciones for update to authenticated using(es_admin()) with check(es_admin());create policy asignaciones_admin_delete on public.asignaciones for delete to authenticated using(es_admin());
create policy matriculas_select on public.matriculas for select to authenticated using(es_admin() or estudiante_id=mi_estudiante_id() or exists(select 1 from asignaciones a where a.curso_id=matriculas.curso_id and a.periodo_id=matriculas.periodo_id and a.docente_id=mi_docente_id()));
create policy matriculas_admin_all on public.matriculas for all to authenticated using(es_admin()) with check(es_admin());

create policy asistencias_select on public.asistencias for select to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id) or (estudiante_id=mi_estudiante_id() and estudiante_pertenece_asignacion(asignacion_id)));
create policy asistencias_write on public.asistencias for insert to authenticated with check(es_admin() or docente_controla_asignacion(asignacion_id));create policy asistencias_update on public.asistencias for update to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id)) with check(es_admin() or docente_controla_asignacion(asignacion_id));create policy asistencias_delete on public.asistencias for delete to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id));
create policy evaluaciones_select on public.evaluaciones for select to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id) or estudiante_pertenece_asignacion(asignacion_id));
create policy evaluaciones_insert on public.evaluaciones for insert to authenticated with check(es_admin() or docente_controla_asignacion(asignacion_id));create policy evaluaciones_update on public.evaluaciones for update to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id)) with check(es_admin() or docente_controla_asignacion(asignacion_id));create policy evaluaciones_delete on public.evaluaciones for delete to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id));
create policy calificaciones_select on public.calificaciones for select to authenticated using(es_admin() or estudiante_id=mi_estudiante_id() or exists(select 1 from evaluaciones e where e.id=calificaciones.evaluacion_id and docente_controla_asignacion(e.asignacion_id)));
create policy calificaciones_insert on public.calificaciones for insert to authenticated with check(es_admin() or exists(select 1 from evaluaciones e where e.id=evaluacion_id and docente_controla_asignacion(e.asignacion_id)));create policy calificaciones_update on public.calificaciones for update to authenticated using(es_admin() or exists(select 1 from evaluaciones e where e.id=evaluacion_id and docente_controla_asignacion(e.asignacion_id))) with check(es_admin() or exists(select 1 from evaluaciones e where e.id=evaluacion_id and docente_controla_asignacion(e.asignacion_id)));create policy calificaciones_delete on public.calificaciones for delete to authenticated using(es_admin() or exists(select 1 from evaluaciones e where e.id=evaluacion_id and docente_controla_asignacion(e.asignacion_id)));
create policy anuncios_select on public.anuncios for select to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id) or estudiante_pertenece_asignacion(asignacion_id));create policy anuncios_insert on public.anuncios for insert to authenticated with check(es_admin() or (publicado_por=auth.uid() and docente_controla_asignacion(asignacion_id)));create policy anuncios_update on public.anuncios for update to authenticated using(es_admin() or (publicado_por=auth.uid() and docente_controla_asignacion(asignacion_id))) with check(es_admin() or (publicado_por=auth.uid() and docente_controla_asignacion(asignacion_id)));create policy anuncios_delete on public.anuncios for delete to authenticated using(es_admin() or (publicado_por=auth.uid() and docente_controla_asignacion(asignacion_id)));
create policy pagos_select on public.pagos for select to authenticated using(es_admin() or estudiante_id=mi_estudiante_id());create policy pagos_admin_all on public.pagos for all to authenticated using(es_admin()) with check(es_admin());

create or replace function public.matricular_estudiante(p_estudiante_id uuid,p_curso_id uuid,p_periodo_id uuid) returns uuid language plpgsql security definer set search_path=public as $$declare nuevo_id uuid;begin if not es_admin() then raise exception 'Permiso insuficiente';end if;if not exists(select 1 from estudiantes where id=p_estudiante_id) then raise exception 'Estudiante inexistente';end if;if not exists(select 1 from cursos where id=p_curso_id) then raise exception 'Curso inexistente';end if;if not exists(select 1 from periodos where id=p_periodo_id and estado='Activo') then raise exception 'El periodo no está activo';end if;insert into matriculas(estudiante_id,curso_id,periodo_id) values(p_estudiante_id,p_curso_id,p_periodo_id) returning id into nuevo_id;return nuevo_id;end;$$;
revoke all on function public.matricular_estudiante(uuid,uuid,uuid) from public;grant execute on function public.matricular_estudiante(uuid,uuid,uuid) to authenticated;

create or replace function public.crear_perfil_usuario() returns trigger language plpgsql security definer set search_path=public as $$begin insert into perfiles(id,nombres,apellidos,email,rol) values(new.id,coalesce(new.raw_user_meta_data->>'nombres',''),coalesce(new.raw_user_meta_data->>'apellidos',''),coalesce(new.email,''),'estudiante') on conflict(id) do nothing;return new;end;$$;
drop trigger if exists al_crear_usuario on auth.users;create trigger al_crear_usuario after insert on auth.users for each row execute procedure public.crear_perfil_usuario();
grant select,insert,update,delete on all tables in schema public to authenticated;
commit;


-- FIN DE LA SECCIÓN 3

-- ============================================================================
-- SECCIÓN 4: PORTAL ESTUDIANTIL
-- ============================================================================
-- Portal estudiantil: horarios, asistencia autónoma controlada y documentos.
-- Depende de la sección de roles y acceso anterior.
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


-- FIN DE LA SECCIÓN 4

-- ============================================================================
-- SECCIÓN 5: DATOS DEL PORTAL ESTUDIANTIL
-- ============================================================================
-- Datos coherentes para probar el portal estudiantil.
-- Primero crea la cuenta estudiante@demo.edu / Estudiante123* desde la app.
-- Después ejecuta este archivo en SQL Editor.
begin;
insert into estudiantes(id,codigo,nombres,apellidos,email,telefono,estado) values('10000000-0000-0000-0000-000000000001','EST-2026-001','Juan','Pérez','estudiante@demo.edu','72900001','Activo') on conflict(codigo) do update set nombres=excluded.nombres,apellidos=excluded.apellidos,email=excluded.email;
insert into docentes(id,codigo,nombres,apellidos,email,especialidad,estado) values
('20000000-0000-0000-0000-000000000001','DOC-001','Carlos','López','carlos@edugestion.edu','Redes y telecomunicaciones','Activo'),
('20000000-0000-0000-0000-000000000002','DOC-002','María','Mendoza','maria@edugestion.edu','Bases de datos','Activo'),
('20000000-0000-0000-0000-000000000003','DOC-003','Luis','Vargas','luis@edugestion.edu','Ingeniería de software','Activo') on conflict(codigo) do nothing;
insert into periodos(id,nombre,fecha_inicio,fecha_fin,estado) values('30000000-0000-0000-0000-000000000001','2026-I','2026-02-02','2026-06-30','Activo') on conflict(nombre) do update set estado='Activo';
insert into materias(id,codigo,nombre,creditos,horas_semanales) values
('40000000-0000-0000-0000-000000000001','INF-301','Redes III',5,6),('40000000-0000-0000-0000-000000000002','INF-302','Base de Datos II',5,6),('40000000-0000-0000-0000-000000000003','INF-303','Ingeniería de Software',5,5),('40000000-0000-0000-0000-000000000004','INF-304','Sistemas Operativos',4,5),('40000000-0000-0000-0000-000000000005','MAT-305','Estadística Aplicada',4,4) on conflict(codigo) do nothing;
insert into cursos(id,nombre,paralelo,gestion,cupo) values
('50000000-0000-0000-0000-000000000001','Redes III','A','2026',35),('50000000-0000-0000-0000-000000000002','Base de Datos II','A','2026',35),('50000000-0000-0000-0000-000000000003','Ingeniería de Software','A','2026',35),('50000000-0000-0000-0000-000000000004','Sistemas Operativos','A','2026',35),('50000000-0000-0000-0000-000000000005','Estadística Aplicada','A','2026',35) on conflict(nombre,paralelo,gestion) do nothing;
insert into asignaciones(id,docente_id,materia_id,curso_id,periodo_id,aula,horario) values
('60000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','Lab. Redes','Lun 08:00 - 10:00'),
('60000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000002','40000000-0000-0000-0000-000000000002','50000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000001','Lab. 3','Mar 10:00 - 12:00'),
('60000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000003','40000000-0000-0000-0000-000000000003','50000000-0000-0000-0000-000000000003','30000000-0000-0000-0000-000000000001','Aula 12','Mié 14:00 - 16:00'),
('60000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000004','50000000-0000-0000-0000-000000000004','30000000-0000-0000-0000-000000000001','Lab. 2','Jue 08:00 - 10:00'),
('60000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000002','40000000-0000-0000-0000-000000000005','50000000-0000-0000-0000-000000000005','30000000-0000-0000-0000-000000000001','Aula 8','Vie 10:00 - 12:00') on conflict(materia_id,curso_id,periodo_id) do nothing;
insert into matriculas(estudiante_id,curso_id,periodo_id) select '10000000-0000-0000-0000-000000000001',id,'30000000-0000-0000-0000-000000000001' from cursos where id::text like '50000000-%' on conflict do nothing;
insert into horarios(asignacion_id,dia_semana,hora_inicio,hora_fin,aula) values
('60000000-0000-0000-0000-000000000001',1,'08:00','10:00','Lab. Redes'),('60000000-0000-0000-0000-000000000002',2,'10:00','12:00','Lab. 3'),('60000000-0000-0000-0000-000000000003',3,'14:00','16:00','Aula 12'),('60000000-0000-0000-0000-000000000004',4,'08:00','10:00','Lab. 2'),('60000000-0000-0000-0000-000000000005',5,'10:00','12:00','Aula 8') on conflict do nothing;
insert into evaluaciones(id,asignacion_id,titulo,tipo,ponderacion,fecha) values('70000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001','Primer parcial','Parcial',30,'2026-03-15'),('70000000-0000-0000-0000-000000000002','60000000-0000-0000-0000-000000000001','Práctica de cableado','Práctico',20,'2026-03-28') on conflict do nothing;
insert into calificaciones(evaluacion_id,estudiante_id,nota) values('70000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001',84),('70000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000001',92) on conflict do nothing;
insert into anuncios(asignacion_id,titulo,contenido,activo) values('60000000-0000-0000-0000-000000000001','Laboratorio del lunes','Traer cable UTP y conectores RJ45.',true),('60000000-0000-0000-0000-000000000002','Material disponible','Las diapositivas de normalización ya están disponibles.',true);
update perfiles set rol='estudiante',estudiante_id='10000000-0000-0000-0000-000000000001',nombres='Juan',apellidos='Pérez',carrera='Ingeniería Informática' where email='estudiante@demo.edu';
commit;


-- FIN DE LA SECCIÓN 5

-- ============================================================================
-- SECCIÓN 6: CUENTAS DE DOCENTE Y ESTUDIANTE
-- ============================================================================
-- Ejecutar después de crear ambos usuarios en Supabase Authentication > Users:
-- estudiante@seminariotarija.edu / Estudiante2026*
-- docente@seminariotarija.edu / Docente2026*
begin;
update estudiantes set email='estudiante@seminariotarija.edu' where id='10000000-0000-0000-0000-000000000001';
update docentes set email='docente@seminariotarija.edu' where id='20000000-0000-0000-0000-000000000001';
update perfiles set rol='estudiante',estudiante_id='10000000-0000-0000-0000-000000000001',docente_id=null,nombres='Juan',apellidos='Pérez',carrera='Ingeniería Informática' where email='estudiante@seminariotarija.edu';
update perfiles set rol='docente',docente_id='20000000-0000-0000-0000-000000000001',estudiante_id=null,nombres='Carlos',apellidos='López' where email='docente@seminariotarija.edu';
commit;

-- Verificación: ambas filas deben mostrar su vínculo y rol.
select email,rol,estudiante_id,docente_id from perfiles where email in ('estudiante@seminariotarija.edu','docente@seminariotarija.edu');


-- FIN DE LA SECCIÓN 6

-- ============================================================================
-- SECCIÓN 7: TAREAS Y ASISTENCIA VINCULADA
-- ============================================================================
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
-- Redes III fue creada en la sección de datos del portal estudiantil.
insert into public.tareas(id,asignacion_id,titulo,descripcion,fecha_limite,puntaje_maximo,estado)
values('71000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001',
       'Diseño de una red institucional','Entregar el diagrama y una breve justificación técnica.',
       '2026-09-15 23:59:00-04',100,'Publicada')
on conflict(id) do nothing;

insert into public.sesiones_asistencia(id,asignacion_id,titulo,fecha,abre_en,cierra_en,activa)
values('72000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001',
       'Clase práctica de Redes III','2026-08-31','2026-08-31 07:00:00-04','2026-08-31 23:00:00-04',true)
on conflict(id) do nothing;


-- FIN DE LA SECCIÓN 7

-- ============================================================================
-- SECCIÓN 8: ARCHIVOS DE ENTREGAS
-- ============================================================================
-- Habilita documentos de texto para entregas y permite al docente leer
-- los adjuntos de tareas pertenecientes a sus asignaciones.
update storage.buckets
set allowed_mime_types = array[
  'text/plain',
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'image/jpeg',
  'image/png'
]
where id = 'documentos-estudiantes';

drop policy if exists storage_entregas_docente_select on storage.objects;
create policy storage_entregas_docente_select
on storage.objects for select to authenticated
using (
  bucket_id = 'documentos-estudiantes'
  and exists (
    select 1
    from public.entregas_tarea e
    join public.tareas t on t.id = e.tarea_id
    where e.archivo_ruta = name
      and docente_controla_asignacion(t.asignacion_id)
  )
);


-- FIN DE LA SECCIÓN 8

-- ============================================================================
-- SECCIÓN 9: ESTUDIANTES Y RENDIMIENTO
-- ============================================================================
-- EduGestion 360: estudiantes adicionales y datos para rendimiento docente.
-- Datos adicionales para verificar el rendimiento docente.
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


-- FIN DE LA SECCIÓN 9
