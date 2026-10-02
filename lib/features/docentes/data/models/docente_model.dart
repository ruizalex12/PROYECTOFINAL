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
    super.direccion,
    super.sexo,
    super.fechaNacimiento,
    super.especialidad,
    super.tituloProfesional,
    super.gradoAcademico,
    super.fechaIncorporacion,
    super.observaciones,
  });

  factory DocenteModel.fromMap(Map<String, dynamic> map) {
    final relation = map['datos_docente'];
    final profesional = relation is Map
        ? Map<String, dynamic>.from(relation)
        : relation is List && relation.isNotEmpty
            ? Map<String, dynamic>.from(relation.first as Map)
            : const <String, dynamic>{};
    return DocenteModel(
      id: map['id'].toString(),
      correo: map['correo'].toString(),
      nombres: map['nombres'].toString(),
      apellidos: map['apellidos'].toString(),
      ci: map['ci'].toString(),
      telefono: map['telefono']?.toString(),
      direccion: map['direccion']?.toString(),
      sexo: map['sexo']?.toString(),
      fechaNacimiento: _date(map['fecha_nacimiento']),
      especialidad: profesional['especialidad']?.toString(),
      tituloProfesional: profesional['titulo_profesional']?.toString(),
      gradoAcademico: profesional['grado_academico']?.toString(),
      fechaIncorporacion: _date(profesional['fecha_incorporacion']),
      observaciones: profesional['observaciones']?.toString(),
      estado: map['estado'] == true,
      fechaRegistro: DateTime.parse(map['fecha_registro'].toString()),
    );
  }

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
