import '../../domain/entities/calificacion.dart';

class CalificacionModel extends Calificacion {
  const CalificacionModel({
    required super.id,
    required super.inscripcionId,
    required super.asignacionDocenteId,
    required super.tipoEvaluacion,
    required super.nota,
    required super.fechaRegistro,
    super.observacion,
  });

  factory CalificacionModel.fromMap(Map<String, dynamic> map) =>
      CalificacionModel(
        id: (map['id_calificacion'] as num).toInt(),
        inscripcionId: (map['inscripcion_id'] as num).toInt(),
        asignacionDocenteId: (map['asignacion_docente_id'] as num).toInt(),
        tipoEvaluacion: map['tipo_evaluacion']?.toString() ?? 'Evaluación',
        nota: (map['nota'] as num).toDouble(),
        observacion: map['observacion']?.toString(),
        fechaRegistro: DateTime.parse(map['fecha_registro'].toString()),
      );
}
