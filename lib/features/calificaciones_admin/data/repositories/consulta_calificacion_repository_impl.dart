import '../../domain/entities/consulta_calificacion.dart';
import '../../domain/repositories/consulta_calificacion_repository.dart';
import '../datasources/consulta_calificacion_remote_datasource.dart';

class ConsultaCalificacionRepositoryImpl
    implements ConsultaCalificacionRepository {
  ConsultaCalificacionRepositoryImpl(this._datasource);
  final ConsultaCalificacionRemoteDatasource _datasource;

  @override
  Future<List<ConsultaCalificacion>> listar(CalificacionAdminFilter filter) =>
      _datasource.listar(filter);

  @override
  Future<CalificacionAdminOptions> cargarOpciones() =>
      _datasource.cargarOpciones();
}
