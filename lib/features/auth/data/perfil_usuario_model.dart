enum RolUsuario { administrador, docente }

class PerfilUsuario {
  const PerfilUsuario({
    required this.id,
    required this.correo,
    required this.nombres,
    required this.apellidos,
    required this.ci,
    required this.rol,
    required this.estado,
    required this.fechaRegistro,
    this.telefono,
  });

  final String id;
  final String correo;
  final String nombres;
  final String apellidos;
  final String ci;
  final String? telefono;
  final RolUsuario rol;
  final bool estado;
  final DateTime fechaRegistro;

  String get nombreCompleto => '$nombres $apellidos'.trim();

  factory PerfilUsuario.fromMap(Map<String, dynamic> map) {
    final rol = switch (map['rol']?.toString()) {
      'ADMINISTRADOR' => RolUsuario.administrador,
      'DOCENTE' => RolUsuario.docente,
      _ => throw const FormatException('Rol de usuario no reconocido.'),
    };

    return PerfilUsuario(
      id: map['id'].toString(),
      correo: map['correo'].toString(),
      nombres: map['nombres'].toString(),
      apellidos: map['apellidos'].toString(),
      ci: map['ci'].toString(),
      telefono: map['telefono']?.toString(),
      rol: rol,
      estado: map['estado'] == true,
      fechaRegistro: DateTime.parse(map['fecha_registro'].toString()),
    );
  }
}
