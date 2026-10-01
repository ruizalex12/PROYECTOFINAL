class Calificacion {
  const Calificacion({
    required this.id,
    required this.inscripcionId,
    required this.asignacionDocenteId,
    required this.tipoEvaluacion,
    required this.nota,
    required this.fechaRegistro,
    this.observacion,
  });

  final int id;
  final int inscripcionId;
  final int asignacionDocenteId;
  final String tipoEvaluacion;
  final double nota;
  final String? observacion;
  final DateTime fechaRegistro;
}

class CalificacionRules {
  const CalificacionRules._();

  static bool notaValida(double nota) => nota >= 0 && nota <= 100;

  static ResultadoAcademico clasificar(double promedio) {
    if (!notaValida(promedio)) {
      throw ArgumentError.value(
          promedio, 'promedio', 'Debe estar entre 0 y 100');
    }
    if (promedio >= 80) return ResultadoAcademico.excelente;
    if (promedio >= 51) return ResultadoAcademico.aprobado;
    return ResultadoAcademico.reprobado;
  }
}

enum ResultadoAcademico { reprobado, aprobado, excelente }

extension ResultadoAcademicoLabel on ResultadoAcademico {
  String get label => switch (this) {
        ResultadoAcademico.reprobado => 'REPROBADO',
        ResultadoAcademico.aprobado => 'APROBADO',
        ResultadoAcademico.excelente => 'EXCELENTE',
      };
}
