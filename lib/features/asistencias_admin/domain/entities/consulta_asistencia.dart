import '../../../asistencia/domain/entities/asistencia.dart';

class ConsultaAsistencia {
  const ConsultaAsistencia({
    required this.id,
    required this.fecha,
    required this.fechaRegistro,
    required this.estado,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteCi,
    required this.asignaturaId,
    required this.asignaturaNombre,
    required this.periodoId,
    required this.periodoNombre,
    required this.docenteId,
    required this.docenteNombre,
    this.estudianteCodigo,
    this.observacion,
  });

  final int id;
  final DateTime fecha;
  final DateTime fechaRegistro;
  final EstadoAsistencia estado;
  final String? observacion;
  final int estudianteId;
  final String? estudianteCodigo;
  final String estudianteNombre;
  final String estudianteCi;
  final int asignaturaId;
  final String asignaturaNombre;
  final int periodoId;
  final String periodoNombre;
  final String docenteId;
  final String docenteNombre;
}

class AsistenciaAdminOption<T> {
  const AsistenciaAdminOption({required this.id, required this.label});

  final T id;
  final String label;
}

class AsistenciaAdminOptions {
  const AsistenciaAdminOptions({
    required this.periodos,
    required this.asignaturas,
    required this.docentes,
  });

  final List<AsistenciaAdminOption<int>> periodos;
  final List<AsistenciaAdminOption<int>> asignaturas;
  final List<AsistenciaAdminOption<String>> docentes;
}

class AsistenciaAdminFilter {
  const AsistenciaAdminFilter({
    this.busqueda = '',
    this.periodoId,
    this.asignaturaId,
    this.estudianteId,
    this.docenteId,
    this.estado,
    this.fechaDesde,
    this.fechaHasta,
  });

  final String busqueda;
  final int? periodoId;
  final int? asignaturaId;
  final int? estudianteId;
  final String? docenteId;
  final EstadoAsistencia? estado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  bool get isEmpty =>
      busqueda.trim().isEmpty &&
      periodoId == null &&
      asignaturaId == null &&
      estudianteId == null &&
      docenteId == null &&
      estado == null &&
      fechaDesde == null &&
      fechaHasta == null;
}

class AsistenciaAdminSummary {
  const AsistenciaAdminSummary({
    required this.total,
    required this.presentes,
    required this.ausentes,
    required this.licencias,
  });

  const AsistenciaAdminSummary.empty()
      : total = 0,
        presentes = 0,
        ausentes = 0,
        licencias = 0;

  final int total;
  final int presentes;
  final int ausentes;
  final int licencias;

  factory AsistenciaAdminSummary.fromItems(List<ConsultaAsistencia> items) =>
      AsistenciaAdminSummary(
        total: items.length,
        presentes: items
            .where((item) => item.estado == EstadoAsistencia.presente)
            .length,
        ausentes: items
            .where((item) => item.estado == EstadoAsistencia.ausente)
            .length,
        licencias: items
            .where((item) => item.estado == EstadoAsistencia.licencia)
            .length,
      );
}
