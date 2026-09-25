class Asignatura {
  const Asignatura({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.estado,
    required this.fechaRegistro,
    this.descripcion,
  });

  final int id;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final bool estado;
  final DateTime fechaRegistro;

  Asignatura copyWith({
    String? codigo,
    String? nombre,
    String? descripcion,
    bool? estado,
  }) {
    return Asignatura(
      id: id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      fechaRegistro: fechaRegistro,
    );
  }
}
