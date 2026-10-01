class EstudianteInscrito {
  const EstudianteInscrito({
    required this.inscripcionId,
    required this.estudianteId,
    required this.nombres,
    required this.apellidos,
    required this.ci,
    required this.estado,
    this.codigo,
    this.telefono,
  });

  final int inscripcionId;
  final int estudianteId;
  final String? codigo;
  final String nombres;
  final String apellidos;
  final String ci;
  final String? telefono;
  final bool estado;

  String get nombreCompleto => '$nombres $apellidos'.trim();
}
