begin;

-- Los privilegios SQL habilitan PostgREST; RLS conserva la autorización fina.
grant select, insert, update on table public.estudiante to authenticated;
grant select, insert, update on table public.estudiante to service_role;
revoke delete on table public.estudiante from authenticated;

-- El trigger se ejecuta con los privilegios del usuario que hace el INSERT y
-- necesita invocar esta función privada para construir el código ESTxxxx.
grant execute
on function private.generar_codigo_estudiante(bigint)
to authenticated;

grant execute
on function private.generar_codigo_estudiante(bigint)
to service_role;

-- Las políticas ya existen en la base. Se valida su semántica sin depender
-- de sus nombres y sin crear ni reemplazar políticas remotas.
do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'estudiante'
      and cmd = 'INSERT'
      and 'authenticated' = any (roles)
      and coalesce(with_check, '') like '%es_administrador%'
  ) then
    raise exception
      'Falta una política INSERT authenticated limitada a ADMINISTRADOR activo.';
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'estudiante'
      and cmd = 'UPDATE'
      and 'authenticated' = any (roles)
      and coalesce(qual, '') like '%es_administrador%'
      and coalesce(with_check, '') like '%es_administrador%'
  ) then
    raise exception
      'Falta una política UPDATE authenticated limitada a ADMINISTRADOR activo.';
  end if;
end
$$;

-- Resuelve la secuencia asociada a la identity sin asumir su nombre físico.
do $$
declare
  v_secuencia regclass;
begin
  v_secuencia := to_regclass(
    pg_get_serial_sequence('public.estudiante', 'id_estudiante')
  );

  if v_secuencia is null then
    raise exception
      'No se encontró la secuencia/identity de public.estudiante.id_estudiante.';
  end if;

  execute format(
    'grant usage, select on sequence %s to authenticated',
    v_secuencia
  );
  execute format(
    'grant usage, select on sequence %s to service_role',
    v_secuencia
  );
end
$$;

commit;
