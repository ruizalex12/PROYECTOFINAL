import '../../domain/entities/estudiante_inscrito.dart';

class EstudianteInscritoModel extends EstudianteInscrito {
  const EstudianteInscritoModel({
    required super.inscripcionId,
    required super.estudianteId,
    required super.nombres,
    required super.apellidos,
    required super.ci,
    required super.estado,
    super.codigo,
    super.telefono,
  });

  factory EstudianteInscritoModel.fromMap(Map<String, dynamic> map) {
    final estudiante = Map<String, dynamic>.from(map['estudiante'] as Map);
    return EstudianteInscritoModel(
      inscripcionId: (map['id_inscripcion'] as num).toInt(),
      estudianteId: (estudiante['id_estudiante'] as num).toInt(),
      codigo: estudiante['codigo']?.toString(),
      nombres: estudiante['nombres'].toString(),
      apellidos: estudiante['apellidos'].toString(),
      ci: estudiante['ci'].toString(),
      telefono: estudiante['telefono']?.toString(),
      estado: map['estado'] == true && estudiante['estado'] == true,
    );
  }
}
