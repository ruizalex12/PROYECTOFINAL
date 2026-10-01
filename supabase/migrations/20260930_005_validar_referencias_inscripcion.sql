-- Impide crear, cambiar referencias o reactivar una inscripción utilizando
-- estudiantes, asignaturas o periodos inactivos. La baja lógica siempre se
-- permite y no altera registros históricos existentes.

create or replace function private.validar_referencias_inscripcion_activas()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_debe_validar boolean;
begin
  v_debe_validar := tg_op = 'INSERT';

  if tg_op = 'UPDATE' then
    v_debe_validar :=
      new.estudiante_id is distinct from old.estudiante_id
      or new.asignatura_id is distinct from old.asignatura_id
      or new.periodo_id is distinct from old.periodo_id
      or (old.estado = false and new.estado = true);
  end if;

  if not v_debe_validar then
    return new;
  end if;

  if not exists (
    select 1 from public.estudiante e
    where e.id_estudiante = new.estudiante_id and e.estado = true
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'ESTUDIANTE_INACTIVO';
  end if;

  if not exists (
    select 1 from public.asignatura a
    where a.id_asignatura = new.asignatura_id and a.estado = true
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'ASIGNATURA_INACTIVA';
  end if;

  if not exists (
    select 1 from public.periodo_academico p
    where p.id_periodo = new.periodo_id and p.estado = true
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'PERIODO_INACTIVO';
  end if;

  return new;
end;
$$;

revoke all on function private.validar_referencias_inscripcion_activas()
from public;

drop trigger if exists inscripcion_validar_referencias_activas
on public.inscripcion;

create trigger inscripcion_validar_referencias_activas
before insert or update of estudiante_id, asignatura_id, periodo_id, estado
on public.inscripcion
for each row
execute function private.validar_referencias_inscripcion_activas();
