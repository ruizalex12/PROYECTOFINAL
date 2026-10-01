import '../../domain/entities/consulta_asistencia.dart';
import '../../domain/repositories/consulta_asistencia_repository.dart';
import '../datasources/consulta_asistencia_remote_datasource.dart';

class ConsultaAsistenciaRepositoryImpl implements ConsultaAsistenciaRepository {
  ConsultaAsistenciaRepositoryImpl(this._datasource);

  final ConsultaAsistenciaRemoteDatasource _datasource;

  @override
  Future<List<ConsultaAsistencia>> listar(AsistenciaAdminFilter filter) =>
      _datasource.listar(filter);

  @override
  Future<AsistenciaAdminOptions> cargarOpciones() =>
      _datasource.cargarOpciones();
}
