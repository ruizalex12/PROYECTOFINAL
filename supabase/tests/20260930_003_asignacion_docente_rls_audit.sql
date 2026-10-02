-- Auditoria estructural del modulo administrativo Asignacion Docente.
-- Ejecutar despues de las migraciones 001, 002 y 003 de 20260930.

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'asignacion_docente'
      and cmd = 'INSERT'
      and coalesce(with_check, '') like '%es_administrador%'
      and coalesce(with_check, '') not like '%es_docente%'
  ) then
    raise exception
      'INSERT de asignacion_docente no esta limitado al Administrador.';
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'asignacion_docente'
      and cmd = 'UPDATE'
      and coalesce(qual, '') like '%es_administrador%'
      and coalesce(with_check, '') like '%es_administrador%'
      and coalesce(qual, '') not like '%es_docente%'
      and coalesce(with_check, '') not like '%es_docente%'
  ) then
    raise exception
      'UPDATE de asignacion_docente no esta limitado al Administrador.';
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'asignacion_docente'
      and cmd = 'SELECT'
      and coalesce(qual, '') like '%es_administrador%'
      and coalesce(qual, '') like '%docente_puede_ver_asignacion%'
  ) then
    raise exception
      'SELECT no conserva acceso administrativo y consulta docente propia.';
  end if;

  if exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'asignacion_docente'
      and cmd in ('DELETE', 'ALL')
  ) then
    raise exception 'No debe existir una politica DELETE.';
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.asignacion_docente'::regclass
      and contype = 'u'
      and conname = 'asignacion_docente_unica'
  ) then
    raise exception 'Falta la restriccion UNIQUE de asignacion docente.';
  end if;

  raise notice 'Auditoria RLS de Asignacion Docente aprobada.';
end
$$;
