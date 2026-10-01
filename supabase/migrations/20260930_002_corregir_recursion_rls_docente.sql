-- E3 - Corrige dependencias circulares entre politicas RLS docentes.
-- Ejecutar despues de 20260930_001_docente_e3_rls.sql.

begin;

create or replace function private.docente_puede_ver_asignacion(
  p_asignacion_id bigint
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
    join public.asignatura a on a.id_asignatura = ad.asignatura_id
    join public.periodo_academico p on p.id_periodo = ad.periodo_id
    join public.perfil_usuario pu on pu.id = ad.docente_id
    where ad.id_asignacion = p_asignacion_id
      and ad.docente_id = auth.uid()
      and ad.estado = true
      and a.estado = true
      and p.estado = true
      and pu.rol = 'DOCENTE'
      and pu.estado = true
  );
$$;

create or replace function private.docente_puede_ver_asignatura(
  p_asignatura_id bigint
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
    join public.asignatura a on a.id_asignatura = ad.asignatura_id
    join public.periodo_academico p on p.id_periodo = ad.periodo_id
    join public.perfil_usuario pu on pu.id = ad.docente_id
    where ad.asignatura_id = p_asignatura_id
      and ad.docente_id = auth.uid()
      and ad.estado = true
      and a.estado = true
      and p.estado = true
      and pu.rol = 'DOCENTE'
      and pu.estado = true
  );
$$;

create or replace function private.docente_puede_ver_inscripcion(
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
    from public.inscripcion i
    join public.asignacion_docente ad
      on ad.asignatura_id = i.asignatura_id
     and ad.periodo_id = i.periodo_id
    join public.asignatura a on a.id_asignatura = i.asignatura_id
    join public.periodo_academico p on p.id_periodo = i.periodo_id
    join public.estudiante e on e.id_estudiante = i.estudiante_id
    join public.perfil_usuario pu on pu.id = ad.docente_id
    where i.id_inscripcion = p_inscripcion_id
      and ad.docente_id = auth.uid()
      and i.estado = true
      and ad.estado = true
      and a.estado = true
      and p.estado = true
      and e.estado = true
      and pu.rol = 'DOCENTE'
      and pu.estado = true
  );
$$;

create or replace function private.docente_puede_ver_estudiante(
  p_estudiante_id bigint
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.estudiante e
    join public.inscripcion i on i.estudiante_id = e.id_estudiante
    join public.asignacion_docente ad
      on ad.asignatura_id = i.asignatura_id
     and ad.periodo_id = i.periodo_id
    join public.asignatura a on a.id_asignatura = i.asignatura_id
    join public.periodo_academico p on p.id_periodo = i.periodo_id
    join public.perfil_usuario pu on pu.id = ad.docente_id
    where e.id_estudiante = p_estudiante_id
      and ad.docente_id = auth.uid()
      and e.estado = true
      and i.estado = true
      and ad.estado = true
      and a.estado = true
      and p.estado = true
      and pu.rol = 'DOCENTE'
      and pu.estado = true
  );
$$;

revoke all on function private.docente_puede_ver_asignacion(bigint)
from public;
revoke all on function private.docente_puede_ver_asignatura(bigint)
from public;
revoke all on function private.docente_puede_ver_inscripcion(bigint)
from public;
revoke all on function private.docente_puede_ver_estudiante(bigint)
from public;

grant execute on function private.docente_puede_ver_asignacion(bigint)
to authenticated;
grant execute on function private.docente_puede_ver_asignatura(bigint)
to authenticated;
grant execute on function private.docente_puede_ver_inscripcion(bigint)
to authenticated;
grant execute on function private.docente_puede_ver_estudiante(bigint)
to authenticated;

drop policy if exists asignacion_docente_select_admin_o_propia_activa
on public.asignacion_docente;
create policy asignacion_docente_select_admin_o_propia_activa
on public.asignacion_docente
for select
to authenticated
using (
  private.es_administrador()
  or private.docente_puede_ver_asignacion(id_asignacion)
);

drop policy if exists asignatura_select_admin_o_docente_asignado_activo
on public.asignatura;
create policy asignatura_select_admin_o_docente_asignado_activo
on public.asignatura
for select
to authenticated
using (
  private.es_administrador()
  or private.docente_puede_ver_asignatura(id_asignatura)
);

drop policy if exists inscripcion_select_admin_o_docente_asignado_activo
on public.inscripcion;
create policy inscripcion_select_admin_o_docente_asignado_activo
on public.inscripcion
for select
to authenticated
using (
  private.es_administrador()
  or private.docente_puede_ver_inscripcion(id_inscripcion)
);

drop policy if exists estudiante_select_admin_o_docente_asignado_activo
on public.estudiante;
create policy estudiante_select_admin_o_docente_asignado_activo
on public.estudiante
for select
to authenticated
using (
  private.es_administrador()
  or private.docente_puede_ver_estudiante(id_estudiante)
);

commit;
