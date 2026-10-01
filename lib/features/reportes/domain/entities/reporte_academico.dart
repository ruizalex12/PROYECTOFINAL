import '../../../calificaciones/domain/entities/calificacion.dart';

enum TipoReporteAcademico {
  inscripciones,
  asistencia,
  calificaciones,
  asignaciones,
}

extension TipoReporteAcademicoLabel on TipoReporteAcademico {
  String get label => switch (this) {
        TipoReporteAcademico.inscripciones => 'Inscripciones',
        TipoReporteAcademico.asistencia => 'Asistencia',
        TipoReporteAcademico.calificaciones => 'Calificaciones',
        TipoReporteAcademico.asignaciones => 'Asignaciones Docentes',
      };
}

class ReporteOption<T> {
  const ReporteOption(this.id, this.label);
  final T id;
  final String label;
}

class ReporteOptions {
  const ReporteOptions({
    this.periodos = const [],
    this.asignaturas = const [],
    this.estudiantes = const [],
    this.docentes = const [],
  });
  final List<ReporteOption<int>> periodos;
  final List<ReporteOption<int>> asignaturas;
  final List<ReporteOption<int>> estudiantes;
  final List<ReporteOption<String>> docentes;
}

class ReporteFilter {
  const ReporteFilter({
    this.periodoId,
    this.asignaturaId,
    this.estudianteId,
    this.docenteId,
    this.estado,
    this.fechaDesde,
    this.fechaHasta,
  });
  final int? periodoId;
  final int? asignaturaId;
  final int? estudianteId;
  final String? docenteId;
  final bool? estado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  bool get isEmpty =>
      periodoId == null &&
      asignaturaId == null &&
      estudianteId == null &&
      docenteId == null &&
      estado == null &&
      fechaDesde == null &&
      fechaHasta == null;
}

class ReporteInscripcionItem {
  const ReporteInscripcionItem({
    required this.id,
    required this.estudianteId,
    required this.estudiante,
    required this.codigo,
    required this.ci,
    required this.asignatura,
    required this.periodo,
    required this.fecha,
    required this.estado,
  });
  final int id;
  final int estudianteId;
  final String estudiante;
  final String codigo;
  final String ci;
  final String asignatura;
  final String periodo;
  final DateTime fecha;
  final bool estado;
}

class ReporteAsignacionItem {
  const ReporteAsignacionItem({
    required this.id,
    required this.docente,
    required this.asignatura,
    required this.periodo,
    required this.fecha,
    required this.estado,
  });
  final int id;
  final String docente;
  final String asignatura;
  final String periodo;
  final DateTime fecha;
  final bool estado;
}

class ReporteAsistenciaItem {
  const ReporteAsistenciaItem({
    required this.estudiante,
    required this.asignatura,
    required this.periodo,
    required this.docente,
    required this.presentes,
    required this.ausentes,
    required this.licencias,
  });
  final String estudiante;
  final String asignatura;
  final String periodo;
  final String docente;
  final int presentes;
  final int ausentes;
  final int licencias;
  int get total => presentes + ausentes + licencias;
  double get porcentaje => total == 0 ? 0 : presentes * 100 / total;
}

class ReporteCalificacionItem {
  const ReporteCalificacionItem({
    required this.estudiante,
    required this.asignatura,
    required this.periodo,
    required this.docente,
    required this.evaluaciones,
    required this.promedio,
    required this.minima,
    required this.maxima,
  });
  final String estudiante;
  final String asignatura;
  final String periodo;
  final String docente;
  final int evaluaciones;
  final double promedio;
  final double minima;
  final double maxima;
  ResultadoAcademico get resultado => CalificacionRules.clasificar(promedio);
}

class ReporteEstadoSummary {
  const ReporteEstadoSummary(this.total, this.activos, this.inactivos);
  final int total;
  final int activos;
  final int inactivos;
}

class ReporteCalificacionSummary {
  const ReporteCalificacionSummary({
    required this.total,
    required this.reprobados,
    required this.aprobados,
    required this.excelentes,
    this.promedioGeneral,
  });
  final int total;
  final int reprobados;
  final int aprobados;
  final int excelentes;
  final double? promedioGeneral;
}
