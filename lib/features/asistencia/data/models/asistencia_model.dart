import '../../domain/entities/asistencia.dart';

class AsistenciaModel extends Asistencia {
  const AsistenciaModel({
    required super.id,
    required super.inscripcionId,
    required super.asignacionDocenteId,
    required super.fecha,
    required super.estado,
    super.observacion,
  });

  factory AsistenciaModel.fromMap(Map<String, dynamic> map) => AsistenciaModel(
        id: (map['id_asistencia'] as num).toInt(),
        inscripcionId: (map['inscripcion_id'] as num).toInt(),
        asignacionDocenteId: (map['asignacion_docente_id'] as num).toInt(),
        fecha: DateTime.parse(map['fecha'].toString()),
        estado: EstadoAsistenciaValue.fromDatabase(map['estado'].toString()),
        observacion: map['observacion']?.toString(),
      );
}
