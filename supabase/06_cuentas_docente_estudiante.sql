-- Ejecutar después de crear ambos usuarios en Supabase Authentication > Users:
-- estudiante@seminariotarija.edu / Estudiante2026*
-- docente@seminariotarija.edu / Docente2026*
begin;
update estudiantes set email='estudiante@seminariotarija.edu' where id='10000000-0000-0000-0000-000000000001';
update docentes set email='docente@seminariotarija.edu' where id='20000000-0000-0000-0000-000000000001';
update perfiles set rol='estudiante',estudiante_id='10000000-0000-0000-0000-000000000001',docente_id=null,nombres='Juan',apellidos='Pérez',carrera='Ingeniería Informática' where email='estudiante@seminariotarija.edu';
update perfiles set rol='docente',docente_id='20000000-0000-0000-0000-000000000001',estudiante_id=null,nombres='Carlos',apellidos='López' where email='docente@seminariotarija.edu';
commit;

-- Verificación: ambas filas deben mostrar su vínculo y rol.
select email,rol,estudiante_id,docente_id from perfiles where email in ('estudiante@seminariotarija.edu','docente@seminariotarija.edu');
