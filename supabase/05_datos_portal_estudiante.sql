-- Datos coherentes para probar el portal estudiantil.
-- Primero crea la cuenta estudiante@demo.edu / Estudiante123* desde la app.
-- Después ejecuta este archivo en SQL Editor.
begin;
insert into estudiantes(id,codigo,nombres,apellidos,email,telefono,estado) values('10000000-0000-0000-0000-000000000001','EST-2026-001','Juan','Pérez','estudiante@demo.edu','72900001','Activo') on conflict(codigo) do update set nombres=excluded.nombres,apellidos=excluded.apellidos,email=excluded.email;
insert into docentes(id,codigo,nombres,apellidos,email,especialidad,estado) values
('20000000-0000-0000-0000-000000000001','DOC-001','Carlos','López','carlos@edugestion.edu','Redes y telecomunicaciones','Activo'),
('20000000-0000-0000-0000-000000000002','DOC-002','María','Mendoza','maria@edugestion.edu','Bases de datos','Activo'),
('20000000-0000-0000-0000-000000000003','DOC-003','Luis','Vargas','luis@edugestion.edu','Ingeniería de software','Activo') on conflict(codigo) do nothing;
insert into periodos(id,nombre,fecha_inicio,fecha_fin,estado) values('30000000-0000-0000-0000-000000000001','2026-I','2026-02-02','2026-06-30','Activo') on conflict(nombre) do update set estado='Activo';
insert into materias(id,codigo,nombre,creditos,horas_semanales) values
('40000000-0000-0000-0000-000000000001','INF-301','Redes III',5,6),('40000000-0000-0000-0000-000000000002','INF-302','Base de Datos II',5,6),('40000000-0000-0000-0000-000000000003','INF-303','Ingeniería de Software',5,5),('40000000-0000-0000-0000-000000000004','INF-304','Sistemas Operativos',4,5),('40000000-0000-0000-0000-000000000005','MAT-305','Estadística Aplicada',4,4) on conflict(codigo) do nothing;
insert into cursos(id,nombre,paralelo,gestion,cupo) values
('50000000-0000-0000-0000-000000000001','Redes III','A','2026',35),('50000000-0000-0000-0000-000000000002','Base de Datos II','A','2026',35),('50000000-0000-0000-0000-000000000003','Ingeniería de Software','A','2026',35),('50000000-0000-0000-0000-000000000004','Sistemas Operativos','A','2026',35),('50000000-0000-0000-0000-000000000005','Estadística Aplicada','A','2026',35) on conflict(nombre,paralelo,gestion) do nothing;
insert into asignaciones(id,docente_id,materia_id,curso_id,periodo_id,aula,horario) values
('60000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','Lab. Redes','Lun 08:00 - 10:00'),
('60000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000002','40000000-0000-0000-0000-000000000002','50000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000001','Lab. 3','Mar 10:00 - 12:00'),
('60000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000003','40000000-0000-0000-0000-000000000003','50000000-0000-0000-0000-000000000003','30000000-0000-0000-0000-000000000001','Aula 12','Mié 14:00 - 16:00'),
('60000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000004','50000000-0000-0000-0000-000000000004','30000000-0000-0000-0000-000000000001','Lab. 2','Jue 08:00 - 10:00'),
('60000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000002','40000000-0000-0000-0000-000000000005','50000000-0000-0000-0000-000000000005','30000000-0000-0000-0000-000000000001','Aula 8','Vie 10:00 - 12:00') on conflict(materia_id,curso_id,periodo_id) do nothing;
insert into matriculas(estudiante_id,curso_id,periodo_id) select '10000000-0000-0000-0000-000000000001',id,'30000000-0000-0000-0000-000000000001' from cursos where id::text like '50000000-%' on conflict do nothing;
insert into horarios(asignacion_id,dia_semana,hora_inicio,hora_fin,aula) values
('60000000-0000-0000-0000-000000000001',1,'08:00','10:00','Lab. Redes'),('60000000-0000-0000-0000-000000000002',2,'10:00','12:00','Lab. 3'),('60000000-0000-0000-0000-000000000003',3,'14:00','16:00','Aula 12'),('60000000-0000-0000-0000-000000000004',4,'08:00','10:00','Lab. 2'),('60000000-0000-0000-0000-000000000005',5,'10:00','12:00','Aula 8') on conflict do nothing;
insert into evaluaciones(id,asignacion_id,titulo,tipo,ponderacion,fecha) values('70000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001','Primer parcial','Parcial',30,'2026-03-15'),('70000000-0000-0000-0000-000000000002','60000000-0000-0000-0000-000000000001','Práctica de cableado','Práctico',20,'2026-03-28') on conflict do nothing;
insert into calificaciones(evaluacion_id,estudiante_id,nota) values('70000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001',84),('70000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000001',92) on conflict do nothing;
insert into anuncios(asignacion_id,titulo,contenido,activo) values('60000000-0000-0000-0000-000000000001','Laboratorio del lunes','Traer cable UTP y conectores RJ45.',true),('60000000-0000-0000-0000-000000000002','Material disponible','Las diapositivas de normalización ya están disponibles.',true);
update perfiles set rol='estudiante',estudiante_id='10000000-0000-0000-0000-000000000001',nombres='Juan',apellidos='Pérez',carrera='Ingeniería Informática' where email='estudiante@demo.edu';
commit;
