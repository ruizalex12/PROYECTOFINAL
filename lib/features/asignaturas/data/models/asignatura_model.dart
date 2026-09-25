import '../../domain/entities/asignatura.dart';

class AsignaturaModel extends Asignatura {
  const AsignaturaModel({
    required super.id,
    required super.codigo,
    required super.nombre,
    required super.estado,
    required super.fechaRegistro,
    super.descripcion,
  });

  factory AsignaturaModel.fromMap(Map<String, dynamic> map) {
    return AsignaturaModel(
      id: (map['id_asignatura'] as num).toInt(),
      codigo: map['codigo'].toString(),
      nombre: map['nombre'].toString(),
      descripcion: map['descripcion']?.toString(),
      estado: map['estado'] == true,
      fechaRegistro: DateTime.parse(map['fecha_registro'].toString()),
    );
  }
}
