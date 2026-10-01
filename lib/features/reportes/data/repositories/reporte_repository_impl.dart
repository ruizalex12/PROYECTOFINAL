import '../../../asistencias_admin/domain/entities/consulta_asistencia.dart';
import '../../../asistencias_admin/domain/repositories/consulta_asistencia_repository.dart';
import '../../../calificaciones_admin/domain/entities/consulta_calificacion.dart';
import '../../../calificaciones_admin/domain/repositories/consulta_calificacion_repository.dart';
import '../../domain/entities/reporte_academico.dart';
import '../../domain/repositories/reporte_repository.dart';
import '../datasources/reporte_remote_datasource.dart';

class ReporteRepositoryImpl implements ReporteRepository {
  ReporteRepositoryImpl(
      this._datasource, this._asistencias, this._calificaciones);
  final ReporteRemoteDatasource _datasource;
  final ConsultaAsistenciaRepository _asistencias;
  final ConsultaCalificacionRepository _calificaciones;

  @override
  Future<ReporteOptions> cargarOpciones() => _datasource.cargarOpciones();
  @override
  Future<List<ReporteInscripcionItem>> inscripciones(ReporteFilter filter) =>
      _datasource.inscripciones(filter);
  @override
  Future<List<ReporteAsignacionItem>> asignaciones(ReporteFilter filter) =>
      _datasource.asignaciones(filter);

  @override
  Future<List<ConsultaAsistencia>> asistencias(ReporteFilter filter) =>
      _asistencias.listar(AsistenciaAdminFilter(
        periodoId: filter.periodoId,
        asignaturaId: filter.asignaturaId,
        estudianteId: filter.estudianteId,
        docenteId: filter.docenteId,
        fechaDesde: filter.fechaDesde,
        fechaHasta: filter.fechaHasta,
      ));

  @override
  Future<List<ConsultaCalificacion>> calificaciones(ReporteFilter filter) =>
      _calificaciones.listar(CalificacionAdminFilter(
        periodoId: filter.periodoId,
        asignaturaId: filter.asignaturaId,
        estudianteId: filter.estudianteId,
        docenteId: filter.docenteId,
      ));
}
