import '../../../asistencia/domain/entities/asistencia.dart';
import '../../../asistencias_admin/domain/entities/consulta_asistencia.dart';
import '../../../calificaciones/domain/entities/calificacion.dart';
import '../../../calificaciones_admin/domain/entities/consulta_calificacion.dart';
import '../entities/reporte_academico.dart';

class ReporteAggregationService {
  const ReporteAggregationService._();

  static List<ReporteAsistenciaItem> asistencia(
    List<ConsultaAsistencia> rows,
  ) {
    final groups = <String, List<ConsultaAsistencia>>{};
    for (final row in rows) {
      final key =
          '${row.estudianteId}|${row.asignaturaId}|${row.periodoId}|${row.docenteId}';
      groups.putIfAbsent(key, () => []).add(row);
    }
    return groups.values.map((items) {
      final first = items.first;
      return ReporteAsistenciaItem(
        estudiante: first.estudianteNombre,
        asignatura: first.asignaturaNombre,
        periodo: first.periodoNombre,
        docente: first.docenteNombre,
        presentes:
            items.where((e) => e.estado == EstadoAsistencia.presente).length,
        ausentes:
            items.where((e) => e.estado == EstadoAsistencia.ausente).length,
        licencias:
            items.where((e) => e.estado == EstadoAsistencia.licencia).length,
      );
    }).toList(growable: false)
      ..sort((a, b) => a.estudiante.compareTo(b.estudiante));
  }

  static List<ReporteCalificacionItem> calificaciones(
    List<ConsultaCalificacion> rows,
  ) {
    final groups = <String, List<ConsultaCalificacion>>{};
    for (final row in rows) {
      final key =
          '${row.estudianteId}|${row.asignaturaId}|${row.periodoId}|${row.docenteId}';
      groups.putIfAbsent(key, () => []).add(row);
    }
    return groups.values.map((items) {
      final first = items.first;
      final notas = items.map((e) => e.nota).toList(growable: false);
      return ReporteCalificacionItem(
        estudiante: first.estudianteNombre,
        asignatura: first.asignaturaNombre,
        periodo: first.periodoNombre,
        docente: first.docenteNombre,
        evaluaciones: notas.length,
        promedio: notas.reduce((a, b) => a + b) / notas.length,
        minima: notas.reduce((a, b) => a < b ? a : b),
        maxima: notas.reduce((a, b) => a > b ? a : b),
      );
    }).toList(growable: false)
      ..sort((a, b) => a.estudiante.compareTo(b.estudiante));
  }

  static ReporteEstadoSummary estado(Iterable<bool> estados) {
    final values = estados.toList(growable: false);
    final activos = values.where((e) => e).length;
    return ReporteEstadoSummary(
        values.length, activos, values.length - activos);
  }

  static ReporteCalificacionSummary resumenCalificaciones(
    List<ReporteCalificacionItem> items,
  ) {
    if (items.isEmpty) {
      return const ReporteCalificacionSummary(
        total: 0,
        reprobados: 0,
        aprobados: 0,
        excelentes: 0,
      );
    }
    return ReporteCalificacionSummary(
      total: items.length,
      reprobados: items
          .where((e) => e.resultado == ResultadoAcademico.reprobado)
          .length,
      aprobados:
          items.where((e) => e.resultado == ResultadoAcademico.aprobado).length,
      excelentes: items
          .where((e) => e.resultado == ResultadoAcademico.excelente)
          .length,
      promedioGeneral:
          items.map((e) => e.promedio).reduce((a, b) => a + b) / items.length,
    );
  }
}
