import '../../domain/entities/consulta_calificacion.dart';

class ConsultaCalificacionModel extends ConsultaCalificacion {
  const ConsultaCalificacionModel({
    required super.id,
    required super.fechaRegistro,
    required super.tipoEvaluacion,
    required super.nota,
    required super.estudianteId,
    required super.estudianteNombre,
    required super.estudianteCi,
    required super.asignaturaId,
    required super.asignaturaNombre,
    required super.periodoId,
    required super.periodoNombre,
    required super.docenteId,
    required super.docenteNombre,
    super.estudianteCodigo,
    super.observacion,
  });

  factory ConsultaCalificacionModel.fromMap(Map<String, dynamic> map) {
    final inscripcion = Map<String, dynamic>.from(map['inscripcion'] as Map);
    final estudiante =
        Map<String, dynamic>.from(inscripcion['estudiante'] as Map);
    final asignatura =
        Map<String, dynamic>.from(inscripcion['asignatura'] as Map);
    final periodo = Map<String, dynamic>.from(inscripcion['periodo'] as Map);
    final asignacion = Map<String, dynamic>.from(map['asignacion'] as Map);
    final docente = Map<String, dynamic>.from(asignacion['docente'] as Map);
    return ConsultaCalificacionModel(
      id: (map['id_calificacion'] as num).toInt(),
      fechaRegistro: DateTime.parse(map['fecha_registro'].toString()),
      tipoEvaluacion: map['tipo_evaluacion']?.toString() ?? 'Sin tipo',
      nota: (map['nota'] as num).toDouble(),
      observacion: map['observacion']?.toString(),
      estudianteId: (estudiante['id_estudiante'] as num).toInt(),
      estudianteCodigo: estudiante['codigo']?.toString(),
      estudianteNombre:
          '${estudiante['nombres']} ${estudiante['apellidos']}'.trim(),
      estudianteCi: estudiante['ci'].toString(),
      asignaturaId: (asignatura['id_asignatura'] as num).toInt(),
      asignaturaNombre: asignatura['nombre'].toString(),
      periodoId: (periodo['id_periodo'] as num).toInt(),
      periodoNombre: periodo['nombre'].toString(),
      docenteId: docente['id'].toString(),
      docenteNombre: '${docente['nombres']} ${docente['apellidos']}'.trim(),
    );
  }
}
