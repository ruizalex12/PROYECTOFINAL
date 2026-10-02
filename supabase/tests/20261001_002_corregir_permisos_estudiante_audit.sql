-- Auditoría de permisos y RLS de Gestión de Estudiantes.
-- Ejecutar completa en Supabase SQL Editor. No conserva filas de prueba.
-- IMPORTANTE: las secuencias PostgreSQL no son transaccionales. Aunque las
-- filas se revierten, los INSERT de esta auditoría pueden consumir valores de
-- la identity y dejar saltos válidos en la numeración de códigos ESTxxxx.
begin;

do $$
declare
  v_secuencia regclass;
  v_admin uuid;
  v_docente uuid;
  v_estudiante_id bigint;
  v_codigo varchar;
  v_afectadas bigint;
  v_rechazado boolean;
  v_ci_admin text := 'AUD-ADM-' || txid_current()::text;
  v_ci_docente text := 'AUD-DOC-' || txid_current()::text;
begin
  -- 1: RLS continúa activo.
  if not exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'estudiante'
      and c.relrowsecurity
  ) then
    raise exception 'RLS no está habilitado en public.estudiante.';
  end if;

  -- 2: authenticated posee solamente los permisos de escritura requeridos.
  if not has_table_privilege(
    'authenticated', 'public.estudiante', 'SELECT, INSERT, UPDATE'
  ) then
    raise exception
      'authenticated no posee SELECT, INSERT y UPDATE sobre estudiante.';
  end if;

  if has_table_privilege('authenticated', 'public.estudiante', 'DELETE') then
    raise exception 'authenticated no debe poseer DELETE sobre estudiante.';
  end if;

  if not has_function_privilege(
    'authenticated',
    'private.generar_codigo_estudiante(bigint)',
    'EXECUTE'
  ) then
    raise exception
      'authenticated no puede ejecutar private.generar_codigo_estudiante(bigint).';
  end if;

  if not has_function_privilege(
    'service_role',
    'private.generar_codigo_estudiante(bigint)',
    'EXECUTE'
  ) then
    raise exception
      'service_role no puede ejecutar private.generar_codigo_estudiante(bigint).';
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'estudiante'
      and cmd = 'INSERT'
      and 'authenticated' = any (roles)
      and coalesce(with_check, '') like '%es_administrador%'
  ) then
    raise exception 'Falta la política INSERT para ADMINISTRADOR activo.';
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
    raise exception 'Falta la política UPDATE para ADMINISTRADOR activo.';
  end if;

  -- 3: se inspecciona la secuencia real asociada a la columna identity.
  v_secuencia := to_regclass(
    pg_get_serial_sequence('public.estudiante', 'id_estudiante')
  );
  if v_secuencia is null then
    raise exception 'id_estudiante no posee una secuencia/identity resoluble.';
  end if;

  if not has_sequence_privilege('authenticated', v_secuencia, 'USAGE')
     or not has_sequence_privilege('authenticated', v_secuencia, 'SELECT') then
    raise exception
      'authenticated no posee USAGE y SELECT sobre la secuencia %.',
      v_secuencia;
  end if;

  -- 9, 10 y 11: integridad de código automático.
  if not exists (
    select 1
    from pg_attribute
    where attrelid = 'public.estudiante'::regclass
      and attname = 'codigo'
      and attnotnull
      and not attisdropped
  ) then
    raise exception 'estudiante.codigo no conserva NOT NULL.';
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.estudiante'::regclass
      and contype = 'u'
      and pg_get_constraintdef(oid) like '%(codigo)%'
  ) then
    raise exception 'estudiante.codigo no conserva UNIQUE.';
  end if;

  if not exists (
    select 1
    from pg_trigger
    where tgrelid = 'public.estudiante'::regclass
      and tgname = 'estudiante_asignar_codigo'
      and not tgisinternal
      and tgenabled <> 'D'
  ) then
    raise exception 'El trigger estudiante_asignar_codigo no está activo.';
  end if;

  select id into v_admin
  from public.perfil_usuario
  where rol = 'ADMINISTRADOR' and estado = true
  order by id
  limit 1;

  select id into v_docente
  from public.perfil_usuario
  where rol = 'DOCENTE' and estado = true
  order by id
  limit 1;

  -- 4 y 8: el administrador inserta sin id_estudiante ni codigo.
  if v_admin is not null then
    perform set_config('request.jwt.claim.sub', v_admin::text, true);
    execute 'set local role authenticated';

    insert into public.estudiante (nombres, apellidos, ci, telefono, estado)
    values ('Auditoría', 'Administrador', v_ci_admin, null, true)
    returning id_estudiante, codigo into v_estudiante_id, v_codigo;

    if v_estudiante_id is null or v_codigo is null
       or v_codigo !~ '^EST[0-9]{4,}$' then
      execute 'reset role';
      raise exception 'El INSERT no generó un código ESTxxxx válido.';
    end if;

    -- 5: el mismo administrador puede actualizar sin modificar codigo.
    update public.estudiante
    set telefono = '70000000'
    where id_estudiante = v_estudiante_id;
    get diagnostics v_afectadas = row_count;
    execute 'reset role';

    if v_afectadas <> 1 then
      raise exception 'ADMINISTRADOR activo no pudo actualizar estudiante.';
    end if;
  else
    raise notice
      'Pruebas INSERT/UPDATE ADMINISTRADOR omitidas: no existe uno activo.';
  end if;

  if v_docente is not null then
    -- 6: INSERT de DOCENTE debe ser rechazado por RLS.
    perform set_config('request.jwt.claim.sub', v_docente::text, true);
    execute 'set local role authenticated';
    v_rechazado := false;
    begin
      insert into public.estudiante (nombres, apellidos, ci, estado)
      values ('Auditoría', 'Docente', v_ci_docente, true);
    exception
      when insufficient_privilege then
        v_rechazado := true;
    end;
    execute 'reset role';

    if not v_rechazado then
      raise exception 'DOCENTE pudo insertar un estudiante.';
    end if;

    -- 7: UPDATE puede ser rechazado o afectar cero filas por USING de RLS.
    if v_estudiante_id is not null then
      perform set_config('request.jwt.claim.sub', v_docente::text, true);
      execute 'set local role authenticated';
      v_rechazado := false;
      begin
        update public.estudiante
        set telefono = '71111111'
        where id_estudiante = v_estudiante_id;
        get diagnostics v_afectadas = row_count;
        v_rechazado := v_afectadas = 0;
      exception
        when insufficient_privilege then
          v_rechazado := true;
      end;
      execute 'reset role';

      if not v_rechazado then
        raise exception 'DOCENTE pudo actualizar un estudiante.';
      end if;
    else
      raise notice
        'Prueba UPDATE DOCENTE omitida: no se creó fila temporal administrativa.';
    end if;
  else
    raise notice 'Pruebas DOCENTE omitidas: no existe uno activo.';
  end if;

  raise notice 'Secuencia/identity verificada: %.', v_secuencia;
  raise notice 'Auditoría de permisos de Estudiantes aprobada.';
end
$$;

rollback;
