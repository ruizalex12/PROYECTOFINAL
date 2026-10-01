import '../../domain/entities/docente.dart';

class DocenteModel extends Docente {
  const DocenteModel({
    required super.id,
    required super.correo,
    required super.nombres,
    required super.apellidos,
    required super.ci,
    required super.estado,
    required super.fechaRegistro,
    super.telefono,
  });

  factory DocenteModel.fromMap(Map<String, dynamic> map) => DocenteModel(
        id: map['id'].toString(),
        correo: map['correo'].toString(),
        nombres: map['nombres'].toString(),
        apellidos: map['apellidos'].toString(),
        ci: map['ci'].toString(),
        telefono: map['telefono']?.toString(),
        estado: map['estado'] == true,
        fechaRegistro: DateTime.parse(map['fecha_registro'].toString()),
      );
}
