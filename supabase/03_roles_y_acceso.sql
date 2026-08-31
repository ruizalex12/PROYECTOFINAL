-- EduGestión 360 · Roles, vínculos académicos y RLS relacional
-- Ejecutar después de 01_schema_y_rls.sql y 02_gestion_academica.sql.
begin;

alter table public.perfiles add column if not exists email text;
alter table public.perfiles add column if not exists estudiante_id uuid references public.estudiantes(id) on delete set null;
alter table public.perfiles add column if not exists docente_id uuid references public.docentes(id) on delete set null;
update public.perfiles set rol='admin' where rol='administrador';
alter table public.perfiles drop constraint if exists perfiles_rol_check;
alter table public.perfiles add constraint perfiles_rol_check check (rol in ('admin','docente','estudiante'));
alter table public.perfiles alter column rol set default 'estudiante';
create unique index if not exists perfiles_estudiante_unique on public.perfiles(estudiante_id) where estudiante_id is not null;
create unique index if not exists perfiles_docente_unique on public.perfiles(docente_id) where docente_id is not null;

alter table public.anuncios add column if not exists asignacion_id uuid references public.asignaciones(id) on delete cascade;
create index if not exists idx_anuncios_asignacion on public.anuncios(asignacion_id);
alter table public.asistencias drop constraint if exists asistencias_estado_check;
alter table public.asistencias add constraint asistencias_estado_check check (estado in ('Presente','Ausente','Justificado','Retraso','Licencia'));
alter table public.matriculas drop constraint if exists matriculas_estudiante_id_periodo_id_key;
create unique index if not exists matriculas_estudiante_curso_periodo_unique on public.matriculas(estudiante_id,curso_id,periodo_id);

create or replace function public.es_admin() returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from perfiles where id=auth.uid() and rol='admin' and activo);$$;
create or replace function public.mi_docente_id() returns uuid language sql stable security definer set search_path=public as $$select docente_id from perfiles where id=auth.uid() and rol='docente' and activo;$$;
create or replace function public.mi_estudiante_id() returns uuid language sql stable security definer set search_path=public as $$select estudiante_id from perfiles where id=auth.uid() and rol='estudiante' and activo;$$;
create or replace function public.docente_controla_asignacion(p_asignacion uuid) returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from asignaciones where id=p_asignacion and docente_id=mi_docente_id());$$;
create or replace function public.estudiante_pertenece_asignacion(p_asignacion uuid,p_estudiante uuid default null) returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from asignaciones a join matriculas m on m.curso_id=a.curso_id and m.periodo_id=a.periodo_id where a.id=p_asignacion and m.estudiante_id=coalesce(p_estudiante,mi_estudiante_id()) and m.estado='Inscrito');$$;
revoke all on function public.es_admin() from public;revoke all on function public.mi_docente_id() from public;revoke all on function public.mi_estudiante_id() from public;revoke all on function public.docente_controla_asignacion(uuid) from public;revoke all on function public.estudiante_pertenece_asignacion(uuid,uuid) from public;
grant execute on function public.es_admin(),public.mi_docente_id(),public.mi_estudiante_id(),public.docente_controla_asignacion(uuid),public.estudiante_pertenece_asignacion(uuid,uuid) to authenticated;

-- Elimina la política temporal permisiva creada en 02.
do $$declare t text;begin foreach t in array array['perfiles','estudiantes','docentes','periodos','materias','cursos','asignaciones','matriculas','asistencias','evaluaciones','calificaciones','pagos','anuncios'] loop execute format('drop policy if exists "Acceso autenticado" on public.%I',t);end loop;end$$;

-- Perfiles: cada usuario se ve; solo admin administra y cambia roles.
create policy perfiles_select on public.perfiles for select to authenticated using(id=auth.uid() or es_admin());
create policy perfiles_admin_insert on public.perfiles for insert to authenticated with check(es_admin());
create policy perfiles_admin_update on public.perfiles for update to authenticated using(es_admin()) with check(es_admin());
create policy perfiles_admin_delete on public.perfiles for delete to authenticated using(es_admin());

-- Catálogos no sensibles: visibles al autenticado; escritura solo admin.
do $$declare t text;begin foreach t in array array['periodos','materias','cursos'] loop execute format('create policy %I on public.%I for select to authenticated using (true)',t||'_select',t);execute format('create policy %I on public.%I for insert to authenticated with check (es_admin())',t||'_insert_admin',t);execute format('create policy %I on public.%I for update to authenticated using (es_admin()) with check (es_admin())',t||'_update_admin',t);execute format('create policy %I on public.%I for delete to authenticated using (es_admin())',t||'_delete_admin',t);end loop;end$$;

create policy estudiantes_select on public.estudiantes for select to authenticated using(es_admin() or id=mi_estudiante_id() or exists(select 1 from matriculas m join asignaciones a on a.curso_id=m.curso_id and a.periodo_id=m.periodo_id where m.estudiante_id=estudiantes.id and a.docente_id=mi_docente_id()));
create policy estudiantes_admin_insert on public.estudiantes for insert to authenticated with check(es_admin());create policy estudiantes_admin_update on public.estudiantes for update to authenticated using(es_admin()) with check(es_admin());create policy estudiantes_admin_delete on public.estudiantes for delete to authenticated using(es_admin());
create policy docentes_select on public.docentes for select to authenticated using(es_admin() or id=mi_docente_id() or exists(select 1 from asignaciones a where a.docente_id=docentes.id and estudiante_pertenece_asignacion(a.id)));
create policy docentes_admin_insert on public.docentes for insert to authenticated with check(es_admin());create policy docentes_admin_update on public.docentes for update to authenticated using(es_admin()) with check(es_admin());create policy docentes_admin_delete on public.docentes for delete to authenticated using(es_admin());

create policy asignaciones_select on public.asignaciones for select to authenticated using(es_admin() or docente_id=mi_docente_id() or estudiante_pertenece_asignacion(id));
create policy asignaciones_admin_insert on public.asignaciones for insert to authenticated with check(es_admin());create policy asignaciones_admin_update on public.asignaciones for update to authenticated using(es_admin()) with check(es_admin());create policy asignaciones_admin_delete on public.asignaciones for delete to authenticated using(es_admin());
create policy matriculas_select on public.matriculas for select to authenticated using(es_admin() or estudiante_id=mi_estudiante_id() or exists(select 1 from asignaciones a where a.curso_id=matriculas.curso_id and a.periodo_id=matriculas.periodo_id and a.docente_id=mi_docente_id()));
create policy matriculas_admin_all on public.matriculas for all to authenticated using(es_admin()) with check(es_admin());

create policy asistencias_select on public.asistencias for select to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id) or (estudiante_id=mi_estudiante_id() and estudiante_pertenece_asignacion(asignacion_id)));
create policy asistencias_write on public.asistencias for insert to authenticated with check(es_admin() or docente_controla_asignacion(asignacion_id));create policy asistencias_update on public.asistencias for update to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id)) with check(es_admin() or docente_controla_asignacion(asignacion_id));create policy asistencias_delete on public.asistencias for delete to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id));
create policy evaluaciones_select on public.evaluaciones for select to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id) or estudiante_pertenece_asignacion(asignacion_id));
create policy evaluaciones_insert on public.evaluaciones for insert to authenticated with check(es_admin() or docente_controla_asignacion(asignacion_id));create policy evaluaciones_update on public.evaluaciones for update to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id)) with check(es_admin() or docente_controla_asignacion(asignacion_id));create policy evaluaciones_delete on public.evaluaciones for delete to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id));
create policy calificaciones_select on public.calificaciones for select to authenticated using(es_admin() or estudiante_id=mi_estudiante_id() or exists(select 1 from evaluaciones e where e.id=calificaciones.evaluacion_id and docente_controla_asignacion(e.asignacion_id)));
create policy calificaciones_insert on public.calificaciones for insert to authenticated with check(es_admin() or exists(select 1 from evaluaciones e where e.id=evaluacion_id and docente_controla_asignacion(e.asignacion_id)));create policy calificaciones_update on public.calificaciones for update to authenticated using(es_admin() or exists(select 1 from evaluaciones e where e.id=evaluacion_id and docente_controla_asignacion(e.asignacion_id))) with check(es_admin() or exists(select 1 from evaluaciones e where e.id=evaluacion_id and docente_controla_asignacion(e.asignacion_id)));create policy calificaciones_delete on public.calificaciones for delete to authenticated using(es_admin() or exists(select 1 from evaluaciones e where e.id=evaluacion_id and docente_controla_asignacion(e.asignacion_id)));
create policy anuncios_select on public.anuncios for select to authenticated using(es_admin() or docente_controla_asignacion(asignacion_id) or estudiante_pertenece_asignacion(asignacion_id));create policy anuncios_insert on public.anuncios for insert to authenticated with check(es_admin() or (publicado_por=auth.uid() and docente_controla_asignacion(asignacion_id)));create policy anuncios_update on public.anuncios for update to authenticated using(es_admin() or (publicado_por=auth.uid() and docente_controla_asignacion(asignacion_id))) with check(es_admin() or (publicado_por=auth.uid() and docente_controla_asignacion(asignacion_id)));create policy anuncios_delete on public.anuncios for delete to authenticated using(es_admin() or (publicado_por=auth.uid() and docente_controla_asignacion(asignacion_id)));
create policy pagos_select on public.pagos for select to authenticated using(es_admin() or estudiante_id=mi_estudiante_id());create policy pagos_admin_all on public.pagos for all to authenticated using(es_admin()) with check(es_admin());

create or replace function public.matricular_estudiante(p_estudiante_id uuid,p_curso_id uuid,p_periodo_id uuid) returns uuid language plpgsql security definer set search_path=public as $$declare nuevo_id uuid;begin if not es_admin() then raise exception 'Permiso insuficiente';end if;if not exists(select 1 from estudiantes where id=p_estudiante_id) then raise exception 'Estudiante inexistente';end if;if not exists(select 1 from cursos where id=p_curso_id) then raise exception 'Curso inexistente';end if;if not exists(select 1 from periodos where id=p_periodo_id and estado='Activo') then raise exception 'El periodo no está activo';end if;insert into matriculas(estudiante_id,curso_id,periodo_id) values(p_estudiante_id,p_curso_id,p_periodo_id) returning id into nuevo_id;return nuevo_id;end;$$;
revoke all on function public.matricular_estudiante(uuid,uuid,uuid) from public;grant execute on function public.matricular_estudiante(uuid,uuid,uuid) to authenticated;

create or replace function public.crear_perfil_usuario() returns trigger language plpgsql security definer set search_path=public as $$begin insert into perfiles(id,nombres,apellidos,email,rol) values(new.id,coalesce(new.raw_user_meta_data->>'nombres',''),coalesce(new.raw_user_meta_data->>'apellidos',''),coalesce(new.email,''),'estudiante') on conflict(id) do nothing;return new;end;$$;
drop trigger if exists al_crear_usuario on auth.users;create trigger al_crear_usuario after insert on auth.users for each row execute procedure public.crear_perfil_usuario();
grant select,insert,update,delete on all tables in schema public to authenticated;
commit;
