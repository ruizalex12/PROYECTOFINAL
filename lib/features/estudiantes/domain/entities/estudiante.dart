class Estudiante {
  const Estudiante({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.ci,
    required this.estado,
    required this.fechaRegistro,
    this.codigo,
    this.telefono,
  });

  final int id;
  final String? codigo;
  final String nombres;
  final String apellidos;
  final String ci;
  final String? telefono;
  final bool estado;
  final DateTime fechaRegistro;

  String get nombreCompleto => '$nombres $apellidos'.trim();
}
