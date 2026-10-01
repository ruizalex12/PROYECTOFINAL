import '../entities/calificacion.dart';

abstract interface class CalificacionRepository {
  Future<List<Calificacion>> listarPorAsignacion(int asignacionId);

  Future<Calificacion> guardar({
    int? id,
    required int inscripcionId,
    required int asignacionId,
    required String tipoEvaluacion,
    required double nota,
    String? observacion,
  });
}
