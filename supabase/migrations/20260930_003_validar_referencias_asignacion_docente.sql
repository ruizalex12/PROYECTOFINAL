-- Valida las referencias activas de una asignacion docente.
-- Ejecutar despues de 20260930_002_corregir_recursion_rls_docente.sql.

begin;

create or replace function private.validar_perfil_docente()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- La baja logica debe seguir siendo posible aunque una referencia ya
  -- haya sido desactivada por el Administrador.
  if new.estado = false then
    return new;
  end if;

  if not exists (
    select 1
    from public.perfil_usuario pu
    where pu.id = new.docente_id
      and pu.rol = 'DOCENTE'
      and pu.estado = true
  ) then
    raise exception 'El perfil seleccionado no es un docente activo.';
  end if;

  if not exists (
    select 1
    from public.asignatura a
    where a.id_asignatura = new.asignatura_id
      and a.estado = true
  ) then
    raise exception 'La asignatura seleccionada no esta activa.';
  end if;

  if not exists (
    select 1
    from public.periodo_academico p
    where p.id_periodo = new.periodo_id
      and p.estado = true
  ) then
    raise exception 'El periodo academico seleccionado no esta activo.';
  end if;

  return new;
end;
$$;

revoke all on function private.validar_perfil_docente() from public;

commit;
