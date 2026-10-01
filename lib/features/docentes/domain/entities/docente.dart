class Docente {
  const Docente({
    required this.id,
    required this.correo,
    required this.nombres,
    required this.apellidos,
    required this.ci,
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
  final bool estado;
  final DateTime fechaRegistro;

  String get nombreCompleto => '$nombres $apellidos'.trim();
}
