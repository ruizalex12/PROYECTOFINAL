import '../../domain/entities/estudiante.dart';

class EstudianteModel extends Estudiante {
  const EstudianteModel({
    required super.id,
    required super.nombres,
    required super.apellidos,
    required super.ci,
    required super.estado,
    required super.fechaRegistro,
    super.codigo,
    super.telefono,
  });

  factory EstudianteModel.fromMap(Map<String, dynamic> map) => EstudianteModel(
        id: (map['id_estudiante'] as num).toInt(),
        codigo: map['codigo']?.toString(),
        nombres: map['nombres'].toString(),
        apellidos: map['apellidos'].toString(),
        ci: map['ci'].toString(),
        telefono: map['telefono']?.toString(),
        estado: map['estado'] == true,
        fechaRegistro: DateTime.parse(map['fecha_registro'].toString()),
      );
}
