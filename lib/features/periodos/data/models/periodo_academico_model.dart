import '../../domain/entities/periodo_academico.dart';

class PeriodoAcademicoModel extends PeriodoAcademico {
  const PeriodoAcademicoModel({
    required super.id,
    required super.nombre,
    required super.fechaInicio,
    required super.fechaFin,
    required super.estado,
  });

  factory PeriodoAcademicoModel.fromMap(Map<String, dynamic> map) =>
      PeriodoAcademicoModel(
        id: (map['id_periodo'] as num).toInt(),
        nombre: map['nombre'].toString(),
        fechaInicio: DateTime.parse(map['fecha_inicio'].toString()),
        fechaFin: DateTime.parse(map['fecha_fin'].toString()),
        estado: map['estado'] == true,
      );
}
