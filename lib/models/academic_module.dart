import 'package:flutter/material.dart';

class AcademicModule {
  const AcademicModule(
      {required this.table,
      required this.title,
      required this.singular,
      required this.icon,
      required this.fields});
  final String table, title, singular;
  final IconData icon;
  final List<AcademicField> fields;
}

class AcademicField {
  const AcademicField(this.key, this.label,
      {this.numeric = false, this.required = true});
  final String key, label;
  final bool numeric, required;
}

const academicModules = <AcademicModule>[
  AcademicModule(
      table: 'estudiantes',
      title: 'Estudiantes',
      singular: 'estudiante',
      icon: Icons.groups_rounded,
      fields: [
        AcademicField('codigo', 'Código'),
        AcademicField('nombres', 'Nombres'),
        AcademicField('apellidos', 'Apellidos'),
        AcademicField('email', 'Correo'),
        AcademicField('telefono', 'Teléfono', required: false)
      ]),
  AcademicModule(
      table: 'docentes',
      title: 'Docentes',
      singular: 'docente',
      icon: Icons.co_present_rounded,
      fields: [
        AcademicField('codigo', 'Código'),
        AcademicField('nombres', 'Nombres'),
        AcademicField('apellidos', 'Apellidos'),
        AcademicField('email', 'Correo'),
        AcademicField('especialidad', 'Especialidad')
      ]),
  AcademicModule(
      table: 'materias',
      title: 'Materias',
      singular: 'materia',
      icon: Icons.menu_book_rounded,
      fields: [
        AcademicField('codigo', 'Sigla'),
        AcademicField('nombre', 'Nombre'),
        AcademicField('creditos', 'Créditos', numeric: true),
        AcademicField('horas_semanales', 'Horas semanales', numeric: true)
      ]),
  AcademicModule(
      table: 'cursos',
      title: 'Cursos',
      singular: 'curso',
      icon: Icons.class_rounded,
      fields: [
        AcademicField('nombre', 'Nombre del curso'),
        AcademicField('paralelo', 'Paralelo'),
        AcademicField('gestion', 'Gestión'),
        AcademicField('cupo', 'Cupo', numeric: true)
      ]),
  AcademicModule(
      table: 'periodos',
      title: 'Periodos',
      singular: 'periodo',
      icon: Icons.calendar_month_rounded,
      fields: [
        AcademicField('nombre', 'Nombre'),
        AcademicField('fecha_inicio', 'Fecha inicio'),
        AcademicField('fecha_fin', 'Fecha fin'),
        AcademicField('estado', 'Estado')
      ]),
  AcademicModule(
      table: 'evaluaciones',
      title: 'Evaluaciones',
      singular: 'evaluación',
      icon: Icons.quiz_rounded,
      fields: [
        AcademicField('asignacion_id', 'ID de asignación'),
        AcademicField('titulo', 'Título'),
        AcademicField('tipo', 'Tipo'),
        AcademicField('ponderacion', 'Porcentaje', numeric: true),
        AcademicField('fecha', 'Fecha')
      ]),
  AcademicModule(
      table: 'calificaciones',
      title: 'Calificaciones',
      singular: 'calificación',
      icon: Icons.grade_rounded,
      fields: [
        AcademicField('evaluacion_id', 'ID de evaluación'),
        AcademicField('estudiante_id', 'ID de estudiante'),
        AcademicField('nota', 'Nota', numeric: true),
        AcademicField('observacion', 'Observación', required: false)
      ]),
  AcademicModule(
      table: 'asistencias',
      title: 'Asistencias',
      singular: 'asistencia',
      icon: Icons.fact_check_rounded,
      fields: [
        AcademicField('asignacion_id', 'ID de asignación'),
        AcademicField('estudiante_id', 'ID de estudiante'),
        AcademicField('fecha', 'Fecha'),
        AcademicField('estado', 'Estado'),
        AcademicField('observacion', 'Observación', required: false)
      ]),
  AcademicModule(
      table: 'pagos',
      title: 'Pagos',
      singular: 'pago',
      icon: Icons.payments_rounded,
      fields: [
        AcademicField('estudiante_id', 'ID de estudiante'),
        AcademicField('concepto', 'Concepto'),
        AcademicField('monto', 'Monto', numeric: true),
        AcademicField('fecha', 'Fecha'),
        AcademicField('estado', 'Estado')
      ]),
  AcademicModule(
      table: 'anuncios',
      title: 'Anuncios',
      singular: 'anuncio',
      icon: Icons.campaign_rounded,
      fields: [
        AcademicField('asignacion_id', 'ID de asignación'),
        AcademicField('titulo', 'Título'),
        AcademicField('contenido', 'Contenido')
      ]),
];
