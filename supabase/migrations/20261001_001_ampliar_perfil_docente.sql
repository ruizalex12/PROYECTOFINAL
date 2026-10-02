-- Amplia los datos personales y separa la informacion profesional docente.
-- No modifica la logica que determina docentes elegibles para asignaciones.

begin;

alter table public.perfil_usuario
  add column if not exists direccion varchar(200),
  add column if not exists sexo varchar(10),
  add column if not exists fecha_nacimiento date;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.perfil_usuario'::regclass
      and conname = 'perfil_usuario_sexo_check'
  ) then
    alter table public.perfil_usuario
      add constraint perfil_usuario_sexo_check
      check (sexo is null or sexo in ('MASCULINO', 'FEMENINO', 'OTRO'));
  end if;
end
$$;

create table if not exists public.datos_docente (
  usuario_id uuid primary key
    references public.perfil_usuario(id) on delete cascade,
  especialidad varchar(150),
  titulo_profesional varchar(200),
  grado_academico varchar(100),
  fecha_incorporacion date,
  observaciones text,
  fecha_registro timestamptz not null default now(),
  fecha_actualizacion timestamptz not null default now()
);

comment on table public.datos_docente is
  'Informacion profesional exclusiva de perfiles con rol DOCENTE.';

create or replace function private.validar_perfil_datos_docente()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1
    from public.perfil_usuario pu
    where pu.id = new.usuario_id
      and pu.rol = 'DOCENTE'
  ) then
    raise exception using
      errcode = '23514',
      message = 'DATOS_DOCENTE_REQUIERE_PERFIL_DOCENTE';
  end if;

  return new;
end;
$$;

revoke all on function private.validar_perfil_datos_docente() from public;

drop trigger if exists datos_docente_validar_perfil
on public.datos_docente;

create trigger datos_docente_validar_perfil
before insert or update of usuario_id on public.datos_docente
for each row
execute function private.validar_perfil_datos_docente();

create or replace function private.actualizar_fecha_datos_docente()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.fecha_actualizacion := now();
  return new;
end;
$$;

revoke all on function private.actualizar_fecha_datos_docente() from public;

drop trigger if exists datos_docente_actualizar_fecha
on public.datos_docente;

create trigger datos_docente_actualizar_fecha
before update on public.datos_docente
for each row
execute function private.actualizar_fecha_datos_docente();

-- Backfill seguro para perfiles docentes ya existentes.
insert into public.datos_docente (usuario_id)
select pu.id
from public.perfil_usuario pu
where pu.rol = 'DOCENTE'
on conflict (usuario_id) do nothing;

alter table public.datos_docente enable row level security;

drop policy if exists datos_docente_select_admin
on public.datos_docente;
create policy datos_docente_select_admin
on public.datos_docente
for select
to authenticated
using (private.es_administrador());

drop policy if exists datos_docente_select_propio_docente
on public.datos_docente;
create policy datos_docente_select_propio_docente
on public.datos_docente
for select
to authenticated
using (
  private.es_docente()
  and usuario_id = (select auth.uid())
);

drop policy if exists datos_docente_insert_admin
on public.datos_docente;
create policy datos_docente_insert_admin
on public.datos_docente
for insert
to authenticated
with check (private.es_administrador());

drop policy if exists datos_docente_update_admin
on public.datos_docente;
create policy datos_docente_update_admin
on public.datos_docente
for update
to authenticated
using (private.es_administrador())
with check (private.es_administrador());

-- RLS limita authenticated; no se concede DELETE a ningun rol de API.
revoke all on table public.datos_docente from anon, authenticated;
grant select, insert, update on table public.datos_docente to authenticated;

-- service_role omite RLS, pero aun necesita privilegios SQL de tabla.
revoke delete on table public.datos_docente from service_role;
grant select, insert, update on table public.datos_docente to service_role;

-- Se explicita tambien el acceso que requieren las Edge Functions actuales
-- para gestionar el perfil, sin ampliar a DELETE.
grant select, insert, update on table public.perfil_usuario to service_role;

-- El codigo del estudiante deriva de su identity; no depende de contar filas.
create or replace function private.generar_codigo_estudiante(
  p_id_estudiante bigint
)
returns varchar
language sql
immutable
strict
set search_path = ''
as $$
  select (
    'EST' || lpad(
      p_id_estudiante::text,
      greatest(4, length(p_id_estudiante::text)),
      '0'
    )
  )::varchar;
$$;

revoke all on function private.generar_codigo_estudiante(bigint) from public;

create or replace function private.asignar_codigo_estudiante()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    new.codigo := private.generar_codigo_estudiante(new.id_estudiante);
  else
    -- El codigo es sistemico e inmutable despues de crear el estudiante.
    new.codigo := old.codigo;
  end if;

  return new;
end;
$$;

revoke all on function private.asignar_codigo_estudiante() from public;

-- Evita una carrera entre el backfill y altas concurrentes.
lock table public.estudiante in share row exclusive mode;

-- No se sobreescriben codigos existentes. Si uno de ellos ocupa el codigo
-- derivado de otro estudiante sin codigo, se aborta antes de cambiar datos.
do $$
begin
  if exists (
    select 1
    from public.estudiante pendiente
    join public.estudiante existente
      on existente.id_estudiante <> pendiente.id_estudiante
     and existente.codigo =
       private.generar_codigo_estudiante(pendiente.id_estudiante)
    where pendiente.codigo is null
  ) then
    raise exception using
      errcode = '23505',
      message = 'CONFLICTO_CODIGO_ESTUDIANTE_EXISTENTE';
  end if;
end
$$;

update public.estudiante
set codigo = private.generar_codigo_estudiante(id_estudiante)
where codigo is null;

alter table public.estudiante
  alter column codigo set not null;

drop trigger if exists estudiante_asignar_codigo
on public.estudiante;

create trigger estudiante_asignar_codigo
before insert or update of codigo on public.estudiante
for each row
execute function private.asignar_codigo_estudiante();

commit;
