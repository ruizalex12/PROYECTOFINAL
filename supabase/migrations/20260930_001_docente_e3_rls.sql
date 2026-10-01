-- E3 - Endurecimiento del acceso docente para RF-09, RF-07 y RF-08.
-- Ejecutar despues de 20260925_001_modelo_inicial.sql y sus politicas RLS.

begin;

create or replace function private.docente_controla_operacion_academica(
  p_asignacion_id bigint,
  p_inscripcion_id bigint
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.asignacion_docente ad
    join public.inscripcion i
      on i.id_inscripcion = p_inscripcion_id
     and i.asignatura_id = ad.asignatura_id
     and i.periodo_id = ad.periodo_id
    join public.asignatura a
      on a.id_asignatura = ad.asignatura_id
    join public.periodo_academico p
      on p.id_periodo = ad.periodo_id
    join public.estudiante e
      on e.id_estudiante = i.estudiante_id
    join public.perfil_usuario pu
      on pu.id = ad.docente_id
    where ad.id_asignacion = p_asignacion_id
      and ad.docente_id = auth.uid()
      and ad.estado = true
      and i.estado = true
      and a.estado = true
      and p.estado = true
      and e.estado = true
      and pu.rol = 'DOCENTE'
      and pu.estado = true
  );
$$;

revoke all on function
  private.docente_controla_operacion_academica(bigint, bigint)
from public;
grant execute on function
  private.docente_controla_operacion_academica(bigint, bigint)
to authenticated;

drop policy if exists asignacion_docente_select_admin_o_propia
on public.asignacion_docente;
create policy asignacion_docente_select_admin_o_propia_activa
on public.asignacion_docente
for select
to authenticated
using (
  private.es_administrador()
  or (
    private.es_docente()
    and docente_id = auth.uid()
    and estado = true
    and exists (
      select 1
      from public.asignatura a
      join public.periodo_academico p
        on p.id_periodo = asignacion_docente.periodo_id
      where a.id_asignatura = asignacion_docente.asignatura_id
        and a.estado = true
        and p.estado = true
    )
  )
);

drop policy if exists asignatura_select_admin_o_docente_asignado
on public.asignatura;
create policy asignatura_select_admin_o_docente_asignado_activo
on public.asignatura
for select
to authenticated
using (
  private.es_administrador()
  or (
    private.es_docente()
    and estado = true
    and exists (
      select 1
      from public.asignacion_docente ad
      join public.periodo_academico p on p.id_periodo = ad.periodo_id
      where ad.asignatura_id = asignatura.id_asignatura
        and ad.docente_id = auth.uid()
        and ad.estado = true
        and p.estado = true
    )
  )
);

drop policy if exists inscripcion_select_admin_o_docente_asignado
on public.inscripcion;
create policy inscripcion_select_admin_o_docente_asignado_activo
on public.inscripcion
for select
to authenticated
using (
  private.es_administrador()
  or (
    private.es_docente()
    and estado = true
    and exists (
      select 1
      from public.asignacion_docente ad
      join public.asignatura a on a.id_asignatura = ad.asignatura_id
      join public.periodo_academico p on p.id_periodo = ad.periodo_id
      join public.estudiante e on e.id_estudiante = inscripcion.estudiante_id
      where ad.docente_id = auth.uid()
        and ad.asignatura_id = inscripcion.asignatura_id
        and ad.periodo_id = inscripcion.periodo_id
        and ad.estado = true
        and a.estado = true
        and p.estado = true
        and e.estado = true
    )
  )
);

drop policy if exists estudiante_select_admin_o_docente_asignado
on public.estudiante;
create policy estudiante_select_admin_o_docente_asignado_activo
on public.estudiante
for select
to authenticated
using (
  private.es_administrador()
  or (
    private.es_docente()
    and estado = true
    and exists (
      select 1
      from public.inscripcion i
      join public.asignacion_docente ad
        on ad.asignatura_id = i.asignatura_id
       and ad.periodo_id = i.periodo_id
      join public.asignatura a on a.id_asignatura = i.asignatura_id
      join public.periodo_academico p on p.id_periodo = i.periodo_id
      where i.estudiante_id = estudiante.id_estudiante
        and i.estado = true
        and ad.docente_id = auth.uid()
        and ad.estado = true
        and a.estado = true
        and p.estado = true
    )
  )
);

drop policy if exists asistencia_select_admin_o_docente_asignado
on public.asistencia;
drop policy if exists asistencia_insert_docente_asignado
on public.asistencia;
drop policy if exists asistencia_update_docente_asignado
on public.asistencia;

create policy asistencia_select_admin_o_docente_autorizado
on public.asistencia
for select
to authenticated
using (
  private.es_administrador()
  or private.docente_controla_operacion_academica(
    asignacion_docente_id,
    inscripcion_id
  )
);

create policy asistencia_insert_docente_autorizado
on public.asistencia
for insert
to authenticated
with check (
  private.docente_controla_operacion_academica(
    asignacion_docente_id,
    inscripcion_id
  )
);

create policy asistencia_update_docente_autorizado
on public.asistencia
for update
to authenticated
using (
  private.docente_controla_operacion_academica(
    asignacion_docente_id,
    inscripcion_id
  )
)
with check (
  private.docente_controla_operacion_academica(
    asignacion_docente_id,
    inscripcion_id
  )
);

drop policy if exists calificacion_select_admin_o_docente_asignado
on public.calificacion;
drop policy if exists calificacion_insert_docente_asignado
on public.calificacion;
drop policy if exists calificacion_update_docente_asignado
on public.calificacion;

create policy calificacion_select_admin_o_docente_autorizado
on public.calificacion
for select
to authenticated
using (
  private.es_administrador()
  or private.docente_controla_operacion_academica(
    asignacion_docente_id,
    inscripcion_id
  )
);

create policy calificacion_insert_docente_autorizado
on public.calificacion
for insert
to authenticated
with check (
  private.docente_controla_operacion_academica(
    asignacion_docente_id,
    inscripcion_id
  )
);

create policy calificacion_update_docente_autorizado
on public.calificacion
for update
to authenticated
using (
  private.docente_controla_operacion_academica(
    asignacion_docente_id,
    inscripcion_id
  )
)
with check (
  private.docente_controla_operacion_academica(
    asignacion_docente_id,
    inscripcion_id
  )
);

commit;
