-- Auditoría estructural de Gestión de Docentes.

do $$
begin
  if not exists (
    select 1 from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'perfil_usuario'
      and c.relrowsecurity
  ) then
    raise exception 'perfil_usuario no tiene RLS habilitado.';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'perfil_usuario'
      and cmd = 'SELECT'
      and coalesce(qual, '') like '%auth.uid()%'
      and coalesce(qual, '') like '%es_administrador%'
  ) then
    raise exception 'Falta SELECT propio o administrativo.';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'perfil_usuario'
      and cmd = 'INSERT'
      and coalesce(with_check, '') like '%es_administrador%'
  ) or not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'perfil_usuario'
      and cmd = 'UPDATE'
      and coalesce(qual, '') like '%es_administrador%'
      and coalesce(with_check, '') like '%es_administrador%'
  ) then
    raise exception 'Faltan políticas administrativas INSERT/UPDATE.';
  end if;

  if exists (
    select 1 from information_schema.role_table_grants
    where table_schema = 'public'
      and table_name = 'perfil_usuario'
      and grantee = 'authenticated'
      and privilege_type = 'DELETE'
  ) then
    raise exception 'authenticated no debe tener DELETE sobre perfil_usuario.';
  end if;

  raise notice 'Auditoría RLS de Docentes aprobada.';
end
$$;
