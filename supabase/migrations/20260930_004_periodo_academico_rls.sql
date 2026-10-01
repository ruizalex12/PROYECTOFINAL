-- Restringe la lectura de periodos al administrador o a periodos asociados
-- con asignaciones activas del Docente autenticado.

create or replace function private.docente_puede_ver_periodo(
  p_periodo_id bigint
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.perfil_usuario pu
    join public.asignacion_docente ad
      on ad.docente_id = pu.id
    where pu.id = (select auth.uid())
      and pu.rol = 'DOCENTE'
      and pu.estado = true
      and ad.periodo_id = p_periodo_id
      and ad.estado = true
  );
$$;

revoke all on function private.docente_puede_ver_periodo(bigint) from public;
grant execute on function private.docente_puede_ver_periodo(bigint)
  to authenticated;

drop policy if exists periodo_academico_select_personal_activo
  on public.periodo_academico;

drop policy if exists periodo_academico_select_admin_o_docente_asignado
  on public.periodo_academico;

create policy periodo_academico_select_admin_o_docente_asignado
on public.periodo_academico
for select
to authenticated
using (
  private.es_administrador()
  or private.docente_puede_ver_periodo(id_periodo)
);
