import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/calificacion.dart';
import '../../domain/repositories/calificacion_repository.dart';
import '../datasources/calificacion_remote_datasource.dart';

class CalificacionRepositoryImpl implements CalificacionRepository {
  CalificacionRepositoryImpl(this._datasource);

  final CalificacionRemoteDatasource _datasource;

  @override
  Future<List<Calificacion>> listarPorAsignacion(int asignacionId) =>
      _datasource.listarPorAsignacion(asignacionId);

  @override
  Future<Calificacion> guardar({
    int? id,
    required int inscripcionId,
    required int asignacionId,
    required String tipoEvaluacion,
    required double nota,
    String? observacion,
  }) {
    final tipo = tipoEvaluacion.trim();
    if (tipo.isEmpty) {
      throw const AppException('El tipo de evaluación es obligatorio.');
    }
    if (!CalificacionRules.notaValida(nota)) {
      throw const AppException('La nota debe estar entre 0 y 100.');
    }
    final detalle = observacion?.trim();
    final optional = detalle == null || detalle.isEmpty ? null : detalle;
    if (id == null) {
      return _datasource.crear(
        inscripcionId: inscripcionId,
        asignacionId: asignacionId,
        tipoEvaluacion: tipo,
        nota: nota,
        observacion: optional,
      );
    }
    return _datasource.actualizar(
      id: id,
      inscripcionId: inscripcionId,
      asignacionId: asignacionId,
      tipoEvaluacion: tipo,
      nota: nota,
      observacion: optional,
    );
  }
}
