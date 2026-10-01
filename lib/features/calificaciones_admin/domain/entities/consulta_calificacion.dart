import '../../../calificaciones/domain/entities/calificacion.dart';

class ConsultaCalificacion {
  const ConsultaCalificacion({
    required this.id,
    required this.fechaRegistro,
    required this.tipoEvaluacion,
    required this.nota,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteCi,
    required this.asignaturaId,
    required this.asignaturaNombre,
    required this.periodoId,
    required this.periodoNombre,
    required this.docenteId,
    required this.docenteNombre,
    this.estudianteCodigo,
    this.observacion,
  });

  final int id;
  final DateTime fechaRegistro;
  final String tipoEvaluacion;
  final double nota;
  final String? observacion;
  final int estudianteId;
  final String? estudianteCodigo;
  final String estudianteNombre;
  final String estudianteCi;
  final int asignaturaId;
  final String asignaturaNombre;
  final int periodoId;
  final String periodoNombre;
  final String docenteId;
  final String docenteNombre;
}

class CalificacionAdminOption<T> {
  const CalificacionAdminOption({required this.id, required this.label});
  final T id;
  final String label;
}

class CalificacionAdminOptions {
  const CalificacionAdminOptions({
    required this.periodos,
    required this.asignaturas,
    required this.docentes,
    required this.tiposEvaluacion,
  });

  final List<CalificacionAdminOption<int>> periodos;
  final List<CalificacionAdminOption<int>> asignaturas;
  final List<CalificacionAdminOption<String>> docentes;
  final List<String> tiposEvaluacion;
}

class CalificacionAdminFilter {
  const CalificacionAdminFilter({
    this.busqueda = '',
    this.periodoId,
    this.asignaturaId,
    this.estudianteId,
    this.docenteId,
    this.tipoEvaluacion,
    this.notaMinima,
    this.notaMaxima,
  });

  final String busqueda;
  final int? periodoId;
  final int? asignaturaId;
  final int? estudianteId;
  final String? docenteId;
  final String? tipoEvaluacion;
  final double? notaMinima;
  final double? notaMaxima;

  bool get isEmpty =>
      busqueda.trim().isEmpty &&
      periodoId == null &&
      asignaturaId == null &&
      estudianteId == null &&
      docenteId == null &&
      tipoEvaluacion == null &&
      notaMinima == null &&
      notaMaxima == null;
}

class CalificacionAdminSummary {
  const CalificacionAdminSummary({
    required this.total,
    required this.promedio,
    required this.notaMinima,
    required this.notaMaxima,
  });

  const CalificacionAdminSummary.empty()
      : total = 0,
        promedio = null,
        notaMinima = null,
        notaMaxima = null;

  final int total;
  final double? promedio;
  final double? notaMinima;
  final double? notaMaxima;

  factory CalificacionAdminSummary.fromItems(
    List<ConsultaCalificacion> items,
  ) {
    if (items.isEmpty) return const CalificacionAdminSummary.empty();
    final notas = items.map((item) => item.nota).toList(growable: false);
    return CalificacionAdminSummary(
      total: items.length,
      promedio: notas.reduce((a, b) => a + b) / notas.length,
      notaMinima: notas.reduce((a, b) => a < b ? a : b),
      notaMaxima: notas.reduce((a, b) => a > b ? a : b),
    );
  }
}

class CalificacionAdminFilterRules {
  const CalificacionAdminFilterRules._();

  static String? validar({double? notaMinima, double? notaMaxima}) {
    if (notaMinima != null && !CalificacionRules.notaValida(notaMinima)) {
      return 'La nota mínima debe estar entre 0 y 100.';
    }
    if (notaMaxima != null && !CalificacionRules.notaValida(notaMaxima)) {
      return 'La nota máxima debe estar entre 0 y 100.';
    }
    if (notaMinima != null && notaMaxima != null && notaMinima > notaMaxima) {
      return 'La nota mínima no puede ser mayor que la nota máxima.';
    }
    return null;
  }
}
