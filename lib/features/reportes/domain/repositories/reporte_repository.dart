import '../../../asistencias_admin/domain/entities/consulta_asistencia.dart';
import '../../../calificaciones_admin/domain/entities/consulta_calificacion.dart';
import '../entities/reporte_academico.dart';

abstract class ReporteRepository {
  Future<ReporteOptions> cargarOpciones();
  Future<List<ReporteInscripcionItem>> inscripciones(ReporteFilter filter);
  Future<List<ConsultaAsistencia>> asistencias(ReporteFilter filter);
  Future<List<ConsultaCalificacion>> calificaciones(ReporteFilter filter);
  Future<List<ReporteAsignacionItem>> asignaciones(ReporteFilter filter);
}
