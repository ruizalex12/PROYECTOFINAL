class PeriodoAcademico {
  const PeriodoAcademico({
    required this.id,
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
  });

  final int id;
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool estado;
}
