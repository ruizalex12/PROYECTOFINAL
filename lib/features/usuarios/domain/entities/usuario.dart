enum UsuarioRol { administrador, docente }

extension UsuarioRolValue on UsuarioRol {
  String get databaseValue => switch (this) {
        UsuarioRol.administrador => 'ADMINISTRADOR',
        UsuarioRol.docente => 'DOCENTE',
      };

  String get label => switch (this) {
        UsuarioRol.administrador => 'Administrador',
        UsuarioRol.docente => 'Docente',
      };
}

class Usuario {
  const Usuario({
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
  final UsuarioRol rol;
  final bool estado;
  final DateTime fechaRegistro;

  String get nombreCompleto => '$nombres $apellidos'.trim();
}
