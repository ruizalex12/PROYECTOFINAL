import '../../../asignaciones_docente/domain/entities/asignacion_docente.dart';
import '../../../asistencia/domain/entities/asistencia.dart';
import '../../../asistencias_admin/domain/entities/consulta_asistencia.dart';
import '../../../calificaciones/domain/entities/calificacion.dart';
import '../../../estudiantes/domain/entities/estudiante_inscrito.dart';

class ResumenAcademicoEstudiante {
  ResumenAcademicoEstudiante({
    required this.estudiante,
    required List<ConsultaAsistencia> asistencias,
    required List<Calificacion> calificaciones,
  })  : asistencias = List.unmodifiable(asistencias),
        calificaciones = List.unmodifiable(calificaciones);

  final EstudianteInscrito estudiante;
  final List<ConsultaAsistencia> asistencias;
  final List<Calificacion> calificaciones;

  int get presentes => asistencias
      .where((item) => item.estado == EstadoAsistencia.presente)
      .length;

  int get ausentes => asistencias
      .where((item) => item.estado == EstadoAsistencia.ausente)
      .length;

  int get licencias => asistencias
      .where((item) => item.estado == EstadoAsistencia.licencia)
      .length;

  double? get porcentajeAsistencia =>
      asistencias.isEmpty ? null : presentes * 100 / asistencias.length;

  double? get promedioCalificaciones => calificaciones.isEmpty
      ? null
      : calificaciones.fold<double>(0, (sum, item) => sum + item.nota) /
          calificaciones.length;
}

class ResumenAcademico {
  ResumenAcademico._({
    required this.asignacion,
    required List<ResumenAcademicoEstudiante> estudiantes,
    required this.presentes,
    required this.ausentes,
    required this.licencias,
    required this.promedioCalificaciones,
    required this.porcentajeAsistencia,
  }) : estudiantes = List.unmodifiable(estudiantes);

  final AsignacionDocente asignacion;
  final List<ResumenAcademicoEstudiante> estudiantes;
  final int presentes;
  final int ausentes;
  final int licencias;
  final double? promedioCalificaciones;
  final double? porcentajeAsistencia;

  int get totalInscritos => estudiantes.length;
  int get totalAsistencias => presentes + ausentes + licencias;

  factory ResumenAcademico.construir({
    required AsignacionDocente asignacion,
    required List<EstudianteInscrito> estudiantes,
    required List<ConsultaAsistencia> asistencias,
    required List<Calificacion> calificaciones,
  }) {
    final inscripcionesPermitidas =
        estudiantes.map((item) => item.inscripcionId).toSet();
    final estudiantesPermitidos =
        estudiantes.map((item) => item.estudianteId).toSet();
    final asistenciasFiltradas = asistencias
        .where((item) => estudiantesPermitidos.contains(item.estudianteId))
        .toList(growable: false);
    final calificacionesFiltradas = calificaciones
        .where((item) => inscripcionesPermitidas.contains(item.inscripcionId))
        .toList(growable: false);

    final filas = estudiantes
        .map(
          (estudiante) => ResumenAcademicoEstudiante(
            estudiante: estudiante,
            asistencias: asistenciasFiltradas
                .where(
                  (item) => item.estudianteId == estudiante.estudianteId,
                )
                .toList(growable: false),
            calificaciones: calificacionesFiltradas
                .where(
                  (item) => item.inscripcionId == estudiante.inscripcionId,
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);

    final presentes = asistenciasFiltradas
        .where((item) => item.estado == EstadoAsistencia.presente)
        .length;
    final ausentes = asistenciasFiltradas
        .where((item) => item.estado == EstadoAsistencia.ausente)
        .length;
    final licencias = asistenciasFiltradas
        .where((item) => item.estado == EstadoAsistencia.licencia)
        .length;
    final totalAsistencias = presentes + ausentes + licencias;

    return ResumenAcademico._(
      asignacion: asignacion,
      estudiantes: filas,
      presentes: presentes,
      ausentes: ausentes,
      licencias: licencias,
      promedioCalificaciones: calificacionesFiltradas.isEmpty
          ? null
          : calificacionesFiltradas.fold<double>(
                0,
                (sum, item) => sum + item.nota,
              ) /
              calificacionesFiltradas.length,
      porcentajeAsistencia:
          totalAsistencias == 0 ? null : presentes * 100 / totalAsistencias,
    );
  }
}
