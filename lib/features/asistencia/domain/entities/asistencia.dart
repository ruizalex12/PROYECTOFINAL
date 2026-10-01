enum EstadoAsistencia { presente, ausente, licencia }

extension EstadoAsistenciaValue on EstadoAsistencia {
  String get databaseValue => switch (this) {
        EstadoAsistencia.presente => 'PRESENTE',
        EstadoAsistencia.ausente => 'AUSENTE',
        EstadoAsistencia.licencia => 'LICENCIA',
      };

  String get label => switch (this) {
        EstadoAsistencia.presente => 'Presente',
        EstadoAsistencia.ausente => 'Ausente',
        EstadoAsistencia.licencia => 'Licencia',
      };

  static EstadoAsistencia fromDatabase(String value) => switch (value) {
        'PRESENTE' => EstadoAsistencia.presente,
        'AUSENTE' => EstadoAsistencia.ausente,
        'LICENCIA' => EstadoAsistencia.licencia,
        _ =>
          throw FormatException('Estado de asistencia no reconocido: $value'),
      };
}

class Asistencia {
  const Asistencia({
    required this.inscripcionId,
    required this.asignacionDocenteId,
    required this.fecha,
    required this.estado,
    this.id,
    this.observacion,
  });

  final int? id;
  final int inscripcionId;
  final int asignacionDocenteId;
  final DateTime fecha;
  final EstadoAsistencia estado;
  final String? observacion;
}
