import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.correo,
    required super.nombres,
    required super.apellidos,
    required super.ci,
    required super.rol,
    required super.estado,
    required super.fechaRegistro,
    super.telefono,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) => UsuarioModel(
        id: map['id'].toString(),
        correo: map['correo'].toString(),
        nombres: map['nombres'].toString(),
        apellidos: map['apellidos'].toString(),
        ci: map['ci'].toString(),
        telefono: map['telefono']?.toString(),
        rol: switch (map['rol']?.toString()) {
          'ADMINISTRADOR' => UsuarioRol.administrador,
          'DOCENTE' => UsuarioRol.docente,
          _ => throw const FormatException('Rol de usuario no reconocido.'),
        },
        estado: map['estado'] == true,
        fechaRegistro: DateTime.parse(map['fecha_registro'].toString()),
      );
}
