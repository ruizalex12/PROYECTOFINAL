-- EduGestion 360 - Row Level Security
-- Ejecutar despues de 20260925_001_modelo_inicial.sql.

begin;

-- Funciones auxiliares. SECURITY DEFINER evita recursion de RLS al consultar
-- el perfil del usuario actual. No exponen datos ni aceptan identificadores
-- de usuario arbitrarios.
create schema if not exists private;

revoke all on schema private from public;
grant usage on schema private to authenticated;

create or replace function private.mi_perfil_esta_activo()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.perfil_usuario
    where id = auth.uid()
      and estado = true
  );
$$;

create or replace function private.es_administrador()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.perfil_usuario
    where id = auth.uid()
      and rol = 'ADMINISTRADOR'
      and estado = true
  );
$$;

create or replace function private.es_docente()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.perfil_usuario
    where id = auth.uid()
      and rol = 'DOCENTE'
      and estado = true
  );
$$;

create or replace function private.docente_controla_asignacion(
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
    join public.perfil_usuario pu on pu.id = ad.docente_id
    where ad.id_asignacion = p_asignacion_id
      and ad.docente_id = auth.uid()
      and ad.estado = true
      and pu.id = auth.uid()
      and pu.rol = 'DOCENTE'
      and pu.estado = true
  );
$$;

revoke all on function private.mi_perfil_esta_activo() from public;
revoke all on function private.es_administrador() from public;
revoke all on function private.es_docente() from public;
revoke all on function private.docente_controla_asignacion(bigint) from public;

grant execute on function private.mi_perfil_esta_activo() to authenticated;
grant execute on function private.es_administrador() to authenticated;
grant execute on function private.es_docente() to authenticated;
grant execute on function private.docente_controla_asignacion(bigint) to authenticated;

alter table public.perfil_usuario enable row level security;
alter table public.estudiante enable row level security;
alter table public.asignatura enable row level security;
alter table public.periodo_academico enable row level security;
alter table public.inscripcion enable row level security;
alter table public.asignacion_docente enable row level security;
alter table public.asistencia enable row level security;
alter table public.calificacion enable row level security;

-- PERFIL_USUARIO
create policy perfil_usuario_select_propio_o_admin
on public.perfil_usuario
for select
to authenticated
using (id = auth.uid() or private.es_administrador());

create policy perfil_usuario_insert_admin
on public.perfil_usuario
for insert
to authenticated
with check (private.es_administrador());

create policy perfil_usuario_update_admin
on public.perfil_usuario
for update
to authenticated
using (private.es_administrador())
with check (private.es_administrador());

-- ESTUDIANTE
create policy estudiante_select_admin_o_docente_asignado
on public.estudiante
for select
to authenticated
using (
  private.es_administrador()
  or (
    private.es_docente()
    and exists (
      select 1
      from public.inscripcion i
      join public.asignacion_docente ad
        on ad.asignatura_id = i.asignatura_id
       and ad.periodo_id = i.periodo_id
      where i.estudiante_id = estudiante.id_estudiante
        and i.estado = true
        and ad.docente_id = auth.uid()
        and ad.estado = true
    )
  )
);

create policy estudiante_insert_admin
on public.estudiante
for insert
to authenticated
with check (private.es_administrador());

create policy estudiante_update_admin
on public.estudiante
for update
to authenticated
using (private.es_administrador())
with check (private.es_administrador());

-- ASIGNATURA: vertical E2.
create policy asignatura_select_admin_o_docente_asignado
on public.asignatura
for select
to authenticated
using (
  private.es_administrador()
  or (
    private.es_docente()
    and exists (
      select 1
      from public.asignacion_docente ad
      where ad.asignatura_id = asignatura.id_asignatura
        and ad.docente_id = auth.uid()
        and ad.estado = true
    )
  )
);

create policy asignatura_insert_admin
on public.asignatura
for insert
to authenticated
with check (private.es_administrador());

create policy asignatura_update_admin
on public.asignatura
for update
to authenticated
using (private.es_administrador())
with check (private.es_administrador());

-- PERIODO_ACADEMICO
create policy periodo_academico_select_personal_activo
on public.periodo_academico
for select
to authenticated
using (private.mi_perfil_esta_activo());

create policy periodo_academico_insert_admin
on public.periodo_academico
for insert
to authenticated
with check (private.es_administrador());

create policy periodo_academico_update_admin
on public.periodo_academico
for update
to authenticated
using (private.es_administrador())
with check (private.es_administrador());

-- INSCRIPCION
create policy inscripcion_select_admin_o_docente_asignado
on public.inscripcion
for select
to authenticated
using (
  private.es_administrador()
  or (
    private.es_docente()
    and exists (
      select 1
      from public.asignacion_docente ad
      where ad.docente_id = auth.uid()
        and ad.asignatura_id = inscripcion.asignatura_id
        and ad.periodo_id = inscripcion.periodo_id
        and ad.estado = true
    )
  )
);

create policy inscripcion_insert_admin
on public.inscripcion
for insert
to authenticated
with check (private.es_administrador());

create policy inscripcion_update_admin
on public.inscripcion
for update
to authenticated
using (private.es_administrador())
with check (private.es_administrador());

-- ASIGNACION_DOCENTE
create policy asignacion_docente_select_admin_o_propia
on public.asignacion_docente
for select
to authenticated
using (
  private.es_administrador()
  or (private.es_docente() and docente_id = auth.uid())
);

create policy asignacion_docente_insert_admin
on public.asignacion_docente
for insert
to authenticated
with check (private.es_administrador());

create policy asignacion_docente_update_admin
on public.asignacion_docente
for update
to authenticated
using (private.es_administrador())
with check (private.es_administrador());

-- ASISTENCIA
create policy asistencia_select_admin_o_docente_asignado
on public.asistencia
for select
to authenticated
using (
  private.es_administrador()
  or private.docente_controla_asignacion(asignacion_docente_id)
);

create policy asistencia_insert_docente_asignado
on public.asistencia
for insert
to authenticated
with check (
  private.docente_controla_asignacion(asignacion_docente_id)
);

create policy asistencia_update_docente_asignado
on public.asistencia
for update
to authenticated
using (
  private.docente_controla_asignacion(asignacion_docente_id)
)
with check (
  private.docente_controla_asignacion(asignacion_docente_id)
);

-- CALIFICACION
create policy calificacion_select_admin_o_docente_asignado
on public.calificacion
for select
to authenticated
using (
  private.es_administrador()
  or private.docente_controla_asignacion(asignacion_docente_id)
);

create policy calificacion_insert_docente_asignado
on public.calificacion
for insert
to authenticated
with check (
  private.docente_controla_asignacion(asignacion_docente_id)
);

create policy calificacion_update_docente_asignado
on public.calificacion
for update
to authenticated
using (
  private.docente_controla_asignacion(asignacion_docente_id)
)
with check (
  private.docente_controla_asignacion(asignacion_docente_id)
);

-- Permisos de tabla. RLS sigue siendo obligatoria y no se concede DELETE.
revoke all on table
  public.perfil_usuario,
  public.estudiante,
  public.asignatura,
  public.periodo_academico,
  public.inscripcion,
  public.asignacion_docente,
  public.asistencia,
  public.calificacion
from anon, authenticated;

grant select, insert, update on table
  public.perfil_usuario,
  public.estudiante,
  public.asignatura,
  public.periodo_academico,
  public.inscripcion,
  public.asignacion_docente,
  public.asistencia,
  public.calificacion
to authenticated;

grant usage, select on sequence
  public.estudiante_id_estudiante_seq,
  public.asignatura_id_asignatura_seq,
  public.periodo_academico_id_periodo_seq,
  public.inscripcion_id_inscripcion_seq,
  public.asignacion_docente_id_asignacion_seq,
  public.asistencia_id_asistencia_seq,
  public.calificacion_id_calificacion_seq
to authenticated;

commit;
