-- Auditoria estructural y conductual de datos personales/profesionales.
-- Ejecutar despues de 20261001_001_ampliar_perfil_docente.sql.
-- Todo cambio de datos realizado por esta auditoria se revierte.

begin;

do $$
declare
  v_docente uuid;
  v_otro_docente uuid;
  v_admin uuid;
  v_total bigint;
  v_visible bigint;
  v_afectadas bigint;
  v_rechazado boolean;
begin
  -- 1 y 2: columnas personales y tabla profesional.
  if (
    select count(*)
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'perfil_usuario'
      and column_name in ('direccion', 'sexo', 'fecha_nacimiento')
  ) <> 3 then
    raise exception 'Faltan columnas personales en perfil_usuario.';
  end if;

  if to_regclass('public.datos_docente') is null then
    raise exception 'No existe public.datos_docente.';
  end if;

  -- 3: la PK de usuario_id y su FK garantizan 1:0..1.
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.datos_docente'::regclass
      and contype = 'p'
      and conkey = array[
        (select attnum from pg_attribute
         where attrelid = 'public.datos_docente'::regclass
           and attname = 'usuario_id')
      ]::smallint[]
  ) or not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.datos_docente'::regclass
      and confrelid = 'public.perfil_usuario'::regclass
      and contype = 'f'
  ) then
    raise exception 'usuario_id no garantiza la relacion 1:1 requerida.';
  end if;

  -- 4: todos los perfiles DOCENTE actuales fueron inicializados.
  if exists (
    select 1
    from public.perfil_usuario pu
    where pu.rol = 'DOCENTE'
      and not exists (
        select 1 from public.datos_docente dd
        where dd.usuario_id = pu.id
      )
  ) then
    raise exception 'Existen perfiles DOCENTE sin datos_docente.';
  end if;

  if not exists (
    select 1 from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'datos_docente'
      and c.relrowsecurity
  ) then
    raise exception 'datos_docente no tiene RLS habilitado.';
  end if;

  if exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'datos_docente'
      and cmd in ('DELETE', 'ALL')
  ) then
    raise exception 'No debe existir una politica DELETE/ALL.';
  end if;

  -- 9: privilegios minimos y ausencia de DELETE.
  if not (
    has_table_privilege('service_role', 'public.datos_docente', 'SELECT')
    and has_table_privilege('service_role', 'public.datos_docente', 'INSERT')
    and has_table_privilege('service_role', 'public.datos_docente', 'UPDATE')
  ) or has_table_privilege(
    'service_role', 'public.datos_docente', 'DELETE'
  ) then
    raise exception 'Privilegios incorrectos para service_role.';
  end if;

  if not (
    has_table_privilege('service_role', 'public.perfil_usuario', 'SELECT')
    and has_table_privilege('service_role', 'public.perfil_usuario', 'INSERT')
    and has_table_privilege('service_role', 'public.perfil_usuario', 'UPDATE')
  ) then
    raise exception 'service_role no puede gestionar perfil_usuario.';
  end if;

  if not (
    has_table_privilege('authenticated', 'public.datos_docente', 'SELECT')
    and has_table_privilege('authenticated', 'public.datos_docente', 'INSERT')
    and has_table_privilege('authenticated', 'public.datos_docente', 'UPDATE')
  ) or has_table_privilege(
    'authenticated', 'public.datos_docente', 'DELETE'
  ) then
    raise exception 'Privilegios incorrectos para authenticated.';
  end if;

  -- El codigo es obligatorio, unico y asignado por un trigger.
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'estudiante'
      and column_name = 'codigo'
      and is_nullable <> 'NO'
  ) or not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.estudiante'::regclass
      and contype = 'u'
      and conkey @> array[
        (select attnum from pg_attribute
         where attrelid = 'public.estudiante'::regclass
           and attname = 'codigo')
      ]::smallint[]
  ) then
    raise exception 'estudiante.codigo no es NOT NULL y UNIQUE.';
  end if;

  if not exists (
    select 1
    from pg_trigger t
    where t.tgrelid = 'public.estudiante'::regclass
      and t.tgname = 'estudiante_asignar_codigo'
      and not t.tgisinternal
      and t.tgenabled <> 'D'
  ) then
    raise exception 'Falta el trigger de codigo automatico de estudiante.';
  end if;

  if private.generar_codigo_estudiante(1) <> 'EST0001'
     or private.generar_codigo_estudiante(25) <> 'EST0025'
     or private.generar_codigo_estudiante(300) <> 'EST0300'
     or private.generar_codigo_estudiante(10000) <> 'EST10000' then
    raise exception 'El formato automatico del codigo de estudiante es incorrecto.';
  end if;

  -- El backfill conserva todas las filas y deja codigo valido en cada una.
  if exists (
    select 1 from public.estudiante
    where codigo is null or btrim(codigo) = ''
  ) then
    raise exception 'Existe un estudiante sin codigo despues del backfill.';
  end if;

  -- La restriccion historica de nota se conserva sin duplicarla.
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.calificacion'::regclass
      and conname = 'calificacion_nota_check'
      and contype = 'c'
      and pg_get_constraintdef(oid) like '%nota%0%100%'
  ) then
    raise exception 'No se conserva el CHECK de nota entre 0 y 100.';
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

  select id into v_otro_docente
  from public.perfil_usuario
  where rol = 'DOCENTE'
    and estado = true
    and id is distinct from v_docente
  order by id
  limit 1;

  select count(*) into v_total from public.datos_docente;

  -- 5: un administrador activo ve todas las filas.
  if v_admin is not null then
    perform set_config('request.jwt.claim.sub', v_admin::text, true);
    execute 'set local role authenticated';
    select count(*) into v_visible from public.datos_docente;
    execute 'reset role';
    if v_visible <> v_total then
      raise exception 'ADMINISTRADOR activo no puede consultar todas las filas.';
    end if;
  else
    raise notice 'Prueba ADMINISTRADOR omitida: no existe uno activo.';
  end if;

  -- El INSERT administrativo se prueba con un perfil DOCENTE real. Se quita
  -- temporalmente su fila para evitar una colision de PK y el ROLLBACK final
  -- restaura el estado original de la base.
  if v_admin is not null and v_docente is not null then
    delete from public.datos_docente where usuario_id = v_docente;

    perform set_config('request.jwt.claim.sub', v_admin::text, true);
    execute 'set local role authenticated';
    insert into public.datos_docente (usuario_id) values (v_docente);
    get diagnostics v_afectadas = row_count;
    execute 'reset role';

    if v_afectadas <> 1 then
      raise exception 'ADMINISTRADOR activo no pudo insertar datos_docente.';
    end if;
  else
    raise notice
      'Prueba INSERT ADMINISTRADOR omitida: falta un administrador o docente activo.';
  end if;

  if v_docente is not null then
    perform set_config('request.jwt.claim.sub', v_docente::text, true);
    execute 'set local role authenticated';

    -- 6: el docente activo solamente ve su propia fila.
    if exists (
      select 1 from public.datos_docente
      where usuario_id <> v_docente
    ) or not exists (
      select 1 from public.datos_docente
      where usuario_id = v_docente
    ) then
      execute 'reset role';
      raise exception 'DOCENTE activo ve filas ajenas o no ve la propia.';
    end if;

    -- 7: UPDATE docente queda filtrado por RLS (cero filas).
    update public.datos_docente
    set observaciones = observaciones
    where usuario_id = v_docente;
    get diagnostics v_afectadas = row_count;
    if v_afectadas <> 0 then
      execute 'reset role';
      raise exception 'DOCENTE pudo modificar datos_docente.';
    end if;

    execute 'reset role';

    -- 8: el intento usa otro perfil DOCENTE real y una PK temporalmente libre,
    -- de modo que el error esperado solamente puede provenir de RLS.
    if v_otro_docente is not null then
      delete from public.datos_docente where usuario_id = v_otro_docente;

      perform set_config('request.jwt.claim.sub', v_docente::text, true);
      execute 'set local role authenticated';
      v_rechazado := false;
      begin
        insert into public.datos_docente (usuario_id)
        values (v_otro_docente);
      exception
        when insufficient_privilege then
          v_rechazado := true;
      end;
      execute 'reset role';

      if not v_rechazado then
        raise exception
          'DOCENTE no fue bloqueado por RLS al insertar para otro docente.';
      end if;
    else
      raise notice
        'Prueba INSERT DOCENTE omitida: no existe un segundo docente activo.';
    end if;
  else
    raise notice 'Pruebas DOCENTE omitidas: no existe uno activo.';
  end if;

  -- 10: el CHECK debe rechazar cualquier sexo fuera del catalogo definido.
  select id into v_admin from public.perfil_usuario order by id limit 1;
  if v_admin is not null then
    v_rechazado := false;
    begin
      update public.perfil_usuario set sexo = 'INVALIDO' where id = v_admin;
    exception
      when check_violation then
        v_rechazado := true;
    end;
    if not v_rechazado then
      raise exception 'perfil_usuario acepta un valor invalido de sexo.';
    end if;
  else
    raise notice 'Prueba de sexo omitida: perfil_usuario esta vacia.';
  end if;

  raise notice 'Auditoria de perfil y datos_docente aprobada.';
end
$$;

rollback;
