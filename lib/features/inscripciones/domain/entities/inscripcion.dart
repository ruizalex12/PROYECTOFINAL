class Inscripcion {
  const Inscripcion({
    required this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteActivo,
    required this.asignaturaId,
    required this.asignaturaCodigo,
    required this.asignaturaNombre,
    required this.asignaturaActiva,
    required this.periodoId,
    required this.periodoNombre,
    required this.periodoActivo,
    required this.fechaInscripcion,
    required this.estado,
  });

  final int id;
  final int estudianteId;
  final String estudianteNombre;
  final bool estudianteActivo;
  final int asignaturaId;
  final String asignaturaCodigo;
  final String asignaturaNombre;
  final bool asignaturaActiva;
  final int periodoId;
  final String periodoNombre;
  final bool periodoActivo;
  final DateTime fechaInscripcion;
  final bool estado;
}

class InscripcionOption {
  const InscripcionOption({required this.id, required this.label});

  final int id;
  final String label;
}

class InscripcionOptions {
  const InscripcionOptions({
    required this.estudiantes,
    required this.asignaturas,
    required this.periodos,
  });

  final List<InscripcionOption> estudiantes;
  final List<InscripcionOption> asignaturas;
  final List<InscripcionOption> periodos;
}
