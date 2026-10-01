import '../../domain/entities/asistencia.dart';
import '../../domain/repositories/asistencia_repository.dart';
import '../datasources/asistencia_remote_datasource.dart';

class AsistenciaRepositoryImpl implements AsistenciaRepository {
  AsistenciaRepositoryImpl(this._datasource);

  final AsistenciaRemoteDatasource _datasource;

  @override
  Future<List<Asistencia>> listarPorFecha({
    required int asignacionId,
    required DateTime fecha,
  }) =>
      _datasource.listarPorFecha(asignacionId: asignacionId, fecha: fecha);

  @override
  Future<List<Asistencia>> guardarTodos(List<Asistencia> registros) =>
      _datasource.guardarTodos(registros);
}
