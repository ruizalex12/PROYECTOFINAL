import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../estudiantes/domain/entities/estudiante_inscrito.dart';
import '../../../estudiantes/domain/repositories/estudiante_repository.dart';
import '../../domain/entities/calificacion.dart';
import '../../domain/repositories/calificacion_repository.dart';

enum CalificacionesViewState { loading, empty, error, data }

class CalificacionesController extends ChangeNotifier {
  CalificacionesController(
    this._calificaciones,
    this._estudiantes,
    this.asignacionId,
  );

  final CalificacionRepository _calificaciones;
  final EstudianteRepository _estudiantes;
  final int asignacionId;

  CalificacionesViewState _state = CalificacionesViewState.loading;
  List<EstudianteInscrito> _estudiantesItems = const [];
  List<Calificacion> _calificacionesItems = const [];
  String? _errorMessage;
  bool _saving = false;

  CalificacionesViewState get state => _state;
  List<EstudianteInscrito> get estudiantes =>
      List.unmodifiable(_estudiantesItems);
  String? get errorMessage => _errorMessage;
  bool get saving => _saving;

  List<Calificacion> calificacionesDe(int inscripcionId) => _calificacionesItems
      .where((item) => item.inscripcionId == inscripcionId)
      .toList(growable: false);

  Future<void> cargar() async {
    _state = CalificacionesViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _estudiantes.listarPorAsignacion(asignacionId),
        _calificaciones.listarPorAsignacion(asignacionId),
      ]);
      _estudiantesItems = results[0] as List<EstudianteInscrito>;
      _calificacionesItems = results[1] as List<Calificacion>;
      _state = _estudiantesItems.isEmpty
          ? CalificacionesViewState.empty
          : CalificacionesViewState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = CalificacionesViewState.error;
    }
    notifyListeners();
  }

  Future<String?> guardar({
    Calificacion? existente,
    required int inscripcionId,
    required String tipoEvaluacion,
    required String nota,
    String? observacion,
  }) async {
    final parsed = double.tryParse(nota.trim().replaceAll(',', '.'));
    if (parsed == null) return 'Ingrese una nota válida.';
    _saving = true;
    notifyListeners();
    try {
      await _calificaciones.guardar(
        id: existente?.id,
        inscripcionId: inscripcionId,
        asignacionId: asignacionId,
        tipoEvaluacion: tipoEvaluacion,
        nota: parsed,
        observacion: observacion,
      );
      await cargar();
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
