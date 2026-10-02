-- Auditoría estructural de RLS para E3.
-- Ejecutar después de aplicar:
-- 20260930_001_docente_e3_rls.sql

do $$
begin
  -- 1. RLS debe estar activo en todas las tablas académicas.
  if exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname in (
        'perfil_usuario',
        'estudiante',
        'asignatura',
        'periodo_academico',
        'inscripcion',
        'asignacion_docente',
        'asistencia',
        'calificacion'
      )
      and not c.relrowsecurity
  ) then
    raise exception
      'Una o más tablas académicas no tienen RLS habilitado.';
  end if;

  -- 2. Ninguna política de escritura de asignaturas debe habilitar docentes.
  if exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'asignatura'
      and roles @> array['authenticated']::name[]
      and cmd in ('INSERT', 'UPDATE', 'ALL')
      and (
        coalesce(qual, '') like '%docente%'
        or coalesce(with_check, '') like '%docente%'
      )
  ) then
    raise exception
      'Existe una política que podría permitir escritura docente en asignatura.';
  end if;

  -- 3. Asistencia INSERT debe validar asignación e inscripción.
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'asistencia'
      and cmd = 'INSERT'
      and coalesce(with_check, '')
          like '%docente_controla_operacion_academica%'
  ) then
    raise exception
      'Falta la validación docente para INSERT en asistencia.';
  end if;

  -- 4. Asistencia UPDATE debe validar filas actuales y valores nuevos.
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'asistencia'
      and cmd = 'UPDATE'
      and coalesce(qual, '')
          like '%docente_controla_operacion_academica%'
      and coalesce(with_check, '')
          like '%docente_controla_operacion_academica%'
  ) then
    raise exception
      'Falta la validación docente para UPDATE en asistencia.';
  end if;

  -- 5. Calificación INSERT debe validar asignación e inscripción.
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'calificacion'
      and cmd = 'INSERT'
      and coalesce(with_check, '')
          like '%docente_controla_operacion_academica%'
  ) then
    raise exception
      'Falta la validación docente para INSERT en calificacion.';
  end if;

  -- 6. Calificación UPDATE debe validar filas actuales y valores nuevos.
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'calificacion'
      and cmd = 'UPDATE'
      and coalesce(qual, '')
          like '%docente_controla_operacion_academica%'
      and coalesce(with_check, '')
          like '%docente_controla_operacion_academica%'
  ) then
    raise exception
      'Falta la validación docente para UPDATE en calificacion.';
  end if;

  -- 7. No se permite borrado físico a authenticated.
  if exists (
    select 1
    from information_schema.role_table_grants
    where table_schema = 'public'
      and table_name in (
        'asignatura',
        'estudiante',
        'periodo_academico',
        'inscripcion',
        'asignacion_docente',
        'perfil_usuario',
        'asistencia',
        'calificacion'
      )
      and grantee = 'authenticated'
      and privilege_type = 'DELETE'
  ) then
    raise exception
      'authenticated no debe tener permiso DELETE sobre tablas académicas.';
  end if;

  raise notice 'Auditoría estructural RLS E3 aprobada.';
end
$$;
