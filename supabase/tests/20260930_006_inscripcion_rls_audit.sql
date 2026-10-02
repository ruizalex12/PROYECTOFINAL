-- Auditoría estructural de Inscripciones.
-- Ejecutar después de 20260930_005_validar_referencias_inscripcion.sql.

do $$
begin
  if not exists (
    select 1 from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'inscripcion'
      and c.relrowsecurity
  ) then
    raise exception 'inscripcion no tiene RLS habilitado.';
  end if;

  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.inscripcion'::regclass
      and contype = 'u'
      and pg_get_constraintdef(oid)
        like '%(estudiante_id, asignatura_id, periodo_id)%'
  ) then
    raise exception 'Falta la restricción inscripcion_unica.';
  end if;

  if not exists (
    select 1 from pg_trigger
    where tgrelid = 'public.inscripcion'::regclass
      and tgname = 'inscripcion_validar_referencias_activas'
      and not tgisinternal
  ) then
    raise exception 'Falta el trigger de referencias activas.';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'inscripcion'
      and cmd = 'SELECT'
      and coalesce(qual, '') like '%docente_puede_ver_inscripcion%'
      and coalesce(qual, '') like '%es_administrador%'
  ) then
    raise exception 'Falta SELECT restringido de inscripciones.';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'inscripcion'
      and cmd = 'INSERT'
      and coalesce(with_check, '') like '%es_administrador%'
  ) or not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'inscripcion'
      and cmd = 'UPDATE'
      and coalesce(qual, '') like '%es_administrador%'
      and coalesce(with_check, '') like '%es_administrador%'
  ) then
    raise exception 'Faltan políticas administrativas INSERT/UPDATE.';
  end if;

  if exists (
    select 1 from information_schema.role_table_grants
    where table_schema = 'public'
      and table_name = 'inscripcion'
      and grantee = 'authenticated'
      and privilege_type = 'DELETE'
  ) then
    raise exception 'authenticated no debe tener DELETE sobre inscripcion.';
  end if;

  raise notice 'Auditoría RLS de Inscripciones aprobada.';
end
$$;
