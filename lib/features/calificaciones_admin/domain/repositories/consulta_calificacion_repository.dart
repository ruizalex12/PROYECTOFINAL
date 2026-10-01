import '../entities/consulta_calificacion.dart';

abstract interface class ConsultaCalificacionRepository {
  Future<List<ConsultaCalificacion>> listar(CalificacionAdminFilter filter);
  Future<CalificacionAdminOptions> cargarOpciones();
}
