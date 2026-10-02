-- Auditoria estructural RLS para RF-03 Gestion de Estudiantes.
-- No modifica datos.

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'estudiante'
      and cmd = 'INSERT'
      and coalesce(with_check, '') like '%es_administrador%'
      and coalesce(with_check, '') not like '%es_docente%'
  ) then
    raise exception 'INSERT de estudiante no esta limitado al Administrador.';
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'estudiante'
      and cmd = 'UPDATE'
      and coalesce(qual, '') like '%es_administrador%'
      and coalesce(with_check, '') like '%es_administrador%'
      and coalesce(qual, '') not like '%es_docente%'
      and coalesce(with_check, '') not like '%es_docente%'
  ) then
    raise exception 'UPDATE de estudiante no esta limitado al Administrador.';
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'estudiante'
      and cmd = 'SELECT'
      and coalesce(qual, '') like '%es_administrador%'
      and coalesce(qual, '') like '%docente_puede_ver_estudiante%'
  ) then
    raise exception
      'SELECT no conserva acceso Admin y consulta Docente relacionada.';
  end if;

  if exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'estudiante'
      and cmd in ('DELETE', 'ALL')
  ) then
    raise exception 'No debe existir una politica DELETE para estudiante.';
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.estudiante'::regclass
      and contype = 'u'
      and pg_get_constraintdef(oid) like '%(ci)%'
  ) then
    raise exception 'Falta la restriccion UNIQUE de CI.';
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.estudiante'::regclass
      and contype = 'u'
      and pg_get_constraintdef(oid) like '%(codigo)%'
  ) then
    raise exception 'Falta la restriccion UNIQUE de codigo.';
  end if;

  raise notice 'Auditoria RLS de Estudiantes aprobada.';
end
$$;
