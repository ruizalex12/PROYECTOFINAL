-- Auditoría estructural del módulo Periodos académicos.
-- Ejecutar después de 20260930_004_periodo_academico_rls.sql.

do $$
begin
  if not exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'periodo_academico'
      and c.relrowsecurity
  ) then
    raise exception 'periodo_academico no tiene RLS habilitado.';
  end if;

  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.periodo_academico'::regclass
      and contype = 'u'
      and pg_get_constraintdef(oid) like '%(nombre)%'
  ) then
    raise exception 'Falta UNIQUE sobre periodo_academico.nombre.';
  end if;

  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.periodo_academico'::regclass
      and contype = 'c'
      and pg_get_constraintdef(oid) like '%fecha_fin >= fecha_inicio%'
  ) then
    raise exception 'Falta CHECK fecha_fin >= fecha_inicio.';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'periodo_academico'
      and cmd = 'SELECT'
      and coalesce(qual, '') like '%docente_puede_ver_periodo%'
      and coalesce(qual, '') like '%es_administrador%'
  ) then
    raise exception 'Falta SELECT restringido para administrador/docente.';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'periodo_academico'
      and cmd = 'INSERT'
      and coalesce(with_check, '') like '%es_administrador%'
  ) or not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'periodo_academico'
      and cmd = 'UPDATE'
      and coalesce(qual, '') like '%es_administrador%'
      and coalesce(with_check, '') like '%es_administrador%'
  ) then
    raise exception 'Faltan políticas administrativas INSERT/UPDATE.';
  end if;

  if exists (
    select 1 from information_schema.role_table_grants
    where table_schema = 'public'
      and table_name = 'periodo_academico'
      and grantee = 'authenticated'
      and privilege_type = 'DELETE'
  ) then
    raise exception 'authenticated no debe tener DELETE sobre periodo_academico.';
  end if;

  raise notice 'Auditoría RLS de Periodos académicos aprobada.';
end
$$;
