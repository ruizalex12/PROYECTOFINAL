import '../entities/consulta_asistencia.dart';

abstract interface class ConsultaAsistenciaRepository {
  Future<List<ConsultaAsistencia>> listar(AsistenciaAdminFilter filter);

  Future<AsistenciaAdminOptions> cargarOpciones();
}
