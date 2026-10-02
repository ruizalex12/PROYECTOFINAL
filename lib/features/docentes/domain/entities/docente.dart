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
    this.direccion,
    this.sexo,
    this.fechaNacimiento,
    this.especialidad,
    this.tituloProfesional,
    this.gradoAcademico,
    this.fechaIncorporacion,
    this.observaciones,
  });

  final String id;
  final String correo;
  final String nombres;
  final String apellidos;
  final String ci;
  final String? telefono;
  final String? direccion;
  final String? sexo;
  final DateTime? fechaNacimiento;
  final String? especialidad;
  final String? tituloProfesional;
  final String? gradoAcademico;
  final DateTime? fechaIncorporacion;
  final String? observaciones;
  final bool estado;
  final DateTime fechaRegistro;

  String get nombreCompleto => '$nombres $apellidos'.trim();

  String get sexoLabel => switch (sexo) {
        'MASCULINO' => 'Masculino',
        'FEMENINO' => 'Femenino',
        'OTRO' => 'Otro',
        _ => 'Sin registrar',
      };
}
