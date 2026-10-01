import '../entities/asistencia.dart';

abstract interface class AsistenciaRepository {
  Future<List<Asistencia>> listarPorFecha({
    required int asignacionId,
    required DateTime fecha,
  });

  Future<List<Asistencia>> guardarTodos(List<Asistencia> registros);
}
