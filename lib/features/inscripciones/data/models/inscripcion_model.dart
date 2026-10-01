import '../../domain/entities/inscripcion.dart';

class InscripcionModel extends Inscripcion {
  const InscripcionModel({
    required super.id,
    required super.estudianteId,
    required super.estudianteNombre,
    required super.estudianteActivo,
    required super.asignaturaId,
    required super.asignaturaCodigo,
    required super.asignaturaNombre,
    required super.asignaturaActiva,
    required super.periodoId,
    required super.periodoNombre,
    required super.periodoActivo,
    required super.fechaInscripcion,
    required super.estado,
  });

  factory InscripcionModel.fromMap(Map<String, dynamic> map) {
    final estudiante = Map<String, dynamic>.from(map['estudiante'] as Map);
    final asignatura = Map<String, dynamic>.from(map['asignatura'] as Map);
    final periodo = Map<String, dynamic>.from(map['periodo_academico'] as Map);
    return InscripcionModel(
      id: (map['id_inscripcion'] as num).toInt(),
      estudianteId: (map['estudiante_id'] as num).toInt(),
      estudianteNombre:
          '${estudiante['nombres']} ${estudiante['apellidos']}'.trim(),
      estudianteActivo: estudiante['estado'] == true,
      asignaturaId: (map['asignatura_id'] as num).toInt(),
      asignaturaCodigo: asignatura['codigo'].toString(),
      asignaturaNombre: asignatura['nombre'].toString(),
      asignaturaActiva: asignatura['estado'] == true,
      periodoId: (map['periodo_id'] as num).toInt(),
      periodoNombre: periodo['nombre'].toString(),
      periodoActivo: periodo['estado'] == true,
      fechaInscripcion: DateTime.parse(map['fecha_inscripcion'].toString()),
      estado: map['estado'] == true,
    );
  }
}
