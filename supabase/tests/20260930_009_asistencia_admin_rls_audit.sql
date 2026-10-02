-- Auditoría estructural de Consulta de Asistencia para Administrador.
-- No modifica políticas ni datos.

do $$
begin
  if not exists (
    select 1 from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'asistencia'
      and c.relrowsecurity
  ) then
    raise exception 'asistencia no tiene RLS habilitado.';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'asistencia'
      and cmd = 'SELECT'
      and coalesce(qual, '') like '%es_administrador%'
      and coalesce(qual, '') like '%docente_controla_operacion_academica%'
  ) then
    raise exception
      'SELECT no conserva acceso Admin y restricción académica Docente.';
  end if;

  if exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'asistencia'
      and cmd in ('SELECT', 'ALL')
      and regexp_replace(coalesce(qual, ''), '\s', '', 'g') in ('true', '(true)')
  ) then
    raise exception 'Asistencia no debe tener una política SELECT abierta.';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'asistencia'
      and cmd = 'INSERT'
      and coalesce(with_check, '')
          like '%docente_controla_operacion_academica%'
      and coalesce(with_check, '') not like '%es_administrador%'
  ) then
    raise exception 'INSERT no conserva la restricción exclusiva Docente.';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'asistencia'
      and cmd = 'UPDATE'
      and coalesce(qual, '') like '%docente_controla_operacion_academica%'
      and coalesce(with_check, '')
          like '%docente_controla_operacion_academica%'
      and coalesce(qual, '') not like '%es_administrador%'
      and coalesce(with_check, '') not like '%es_administrador%'
  ) then
    raise exception 'UPDATE no conserva la restricción exclusiva Docente.';
  end if;

  if exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'asistencia'
      and cmd in ('DELETE', 'ALL')
  ) then
    raise exception 'No debe existir una política DELETE/ALL en asistencia.';
  end if;

  if exists (
    select 1 from information_schema.role_table_grants
    where table_schema = 'public'
      and table_name = 'asistencia'
      and grantee in ('anon', 'authenticated')
      and privilege_type = 'DELETE'
  ) then
    raise exception 'anon/authenticated no deben tener DELETE en asistencia.';
  end if;

  raise notice 'Auditoría RLS de Asistencia Admin aprobada.';
end
$$;
