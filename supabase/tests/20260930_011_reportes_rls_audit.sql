-- Auditoría estructural, de solo lectura, para Reportes Académicos.
-- Ejecutar con una cuenta capaz de consultar los catálogos de PostgreSQL.
do $$
declare
  tabla text;
  tablas text[] := array[
    'estudiante', 'asignatura', 'periodo_academico', 'inscripcion',
    'asignacion_docente', 'asistencia', 'calificacion', 'perfil_usuario'
  ];
begin
  foreach tabla in array tablas loop
    if not exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = tabla and c.relrowsecurity
    ) then
      raise exception 'RLS no está habilitada en public.%', tabla;
    end if;

    if not exists (
      select 1 from pg_policies p
      where p.schemaname = 'public' and p.tablename = tabla
        and p.cmd in ('SELECT', 'ALL')
        and (
          coalesce(p.qual, '') ilike '%es_administrador%'
          or (tabla = 'periodo_academico' and coalesce(p.qual, '') ilike '%mi_perfil_esta_activo%')
        )
    ) then
      raise exception 'No se encontró SELECT administrativo protegido en public.%', tabla;
    end if;

    if exists (
      select 1 from pg_policies p
      where p.schemaname = 'public' and p.tablename = tabla
        and p.cmd in ('SELECT', 'ALL') and lower(trim(coalesce(p.qual, ''))) = 'true'
    ) then
      raise exception 'Política SELECT abierta detectada en public.%', tabla;
    end if;

    if exists (
      select 1 from pg_policies p
      where p.schemaname = 'public' and p.tablename = tabla
        and p.cmd in ('DELETE', 'ALL')
    ) then
      raise exception 'Política DELETE/ALL detectada en public.%', tabla;
    end if;
  end loop;

  if exists (
    select 1 from information_schema.role_table_grants
    where table_schema = 'public' and table_name = any(tablas)
      and grantee in ('anon', 'authenticated') and privilege_type = 'DELETE'
  ) then
    raise exception 'Existe un privilegio DELETE incompatible con Reportes';
  end if;

  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name like 'reporte\_%' escape '\'
  ) then
    raise exception 'Reportes no debe crear tablas persistentes reporte_*';
  end if;
end;
$$;
