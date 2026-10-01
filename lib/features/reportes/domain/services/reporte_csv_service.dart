import '../../../calificaciones/domain/entities/calificacion.dart';
import '../entities/reporte_academico.dart';

class CsvExport {
  const CsvExport(this.fileName, this.content);
  final String fileName;
  final String content;
}

class ReporteCsvService {
  const ReporteCsvService._();

  static CsvExport generar(TipoReporteAcademico tipo, List<Object> items,
      {DateTime? now}) {
    final date = now ?? DateTime.now();
    final suffix = '${date.year}${_two(date.month)}${_two(date.day)}';
    final name = switch (tipo) {
      TipoReporteAcademico.inscripciones => 'reporte_inscripciones_$suffix.csv',
      TipoReporteAcademico.asistencia => 'reporte_asistencia_$suffix.csv',
      TipoReporteAcademico.calificaciones =>
        'reporte_calificaciones_$suffix.csv',
      TipoReporteAcademico.asignaciones => 'reporte_asignaciones_$suffix.csv',
    };
    final rows = switch (tipo) {
      TipoReporteAcademico.inscripciones =>
        _inscripciones(items.cast<ReporteInscripcionItem>()),
      TipoReporteAcademico.asistencia =>
        _asistencia(items.cast<ReporteAsistenciaItem>()),
      TipoReporteAcademico.calificaciones =>
        _calificaciones(items.cast<ReporteCalificacionItem>()),
      TipoReporteAcademico.asignaciones =>
        _asignaciones(items.cast<ReporteAsignacionItem>()),
    };
    return CsvExport(name, '\uFEFF${rows.map(_row).join('\r\n')}');
  }

  static List<List<Object?>> _inscripciones(
          List<ReporteInscripcionItem> items) =>
      [
        [
          'Estudiante',
          'Código',
          'CI',
          'Asignatura',
          'Periodo',
          'Fecha de inscripción',
          'Estado'
        ],
        for (final e in items)
          [
            e.estudiante,
            e.codigo,
            e.ci,
            e.asignatura,
            e.periodo,
            _date(e.fecha),
            e.estado ? 'ACTIVA' : 'INACTIVA'
          ],
      ];
  static List<List<Object?>> _asistencia(List<ReporteAsistenciaItem> items) => [
        [
          'Estudiante',
          'Asignatura',
          'Periodo',
          'Docente',
          'Presentes',
          'Ausentes',
          'Licencias',
          'Total',
          'Porcentaje'
        ],
        for (final e in items)
          [
            e.estudiante,
            e.asignatura,
            e.periodo,
            e.docente,
            e.presentes,
            e.ausentes,
            e.licencias,
            e.total,
            e.porcentaje.toStringAsFixed(2)
          ],
      ];
  static List<List<Object?>> _calificaciones(
          List<ReporteCalificacionItem> items) =>
      [
        [
          'Estudiante',
          'Asignatura',
          'Periodo',
          'Docente',
          'Evaluaciones',
          'Promedio',
          'Mínima',
          'Máxima',
          'Resultado académico'
        ],
        for (final e in items)
          [
            e.estudiante,
            e.asignatura,
            e.periodo,
            e.docente,
            e.evaluaciones,
            e.promedio.toStringAsFixed(2),
            e.minima.toStringAsFixed(2),
            e.maxima.toStringAsFixed(2),
            e.resultado.label
          ],
      ];
  static List<List<Object?>> _asignaciones(List<ReporteAsignacionItem> items) =>
      [
        ['Docente', 'Asignatura', 'Periodo', 'Fecha de asignación', 'Estado'],
        for (final e in items)
          [
            e.docente,
            e.asignatura,
            e.periodo,
            _date(e.fecha),
            e.estado ? 'ACTIVA' : 'INACTIVA'
          ],
      ];
  static String _row(List<Object?> cells) => cells
      .map((e) => '"${(e ?? '').toString().replaceAll('"', '""')}"')
      .join(',');
  static String _date(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';
  static String _two(int value) => value.toString().padLeft(2, '0');
}
