import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/estudiante_inscrito.dart';
import '../../domain/repositories/estudiante_repository.dart';

enum EstudiantesAsignacionState { loading, empty, error, data }

class EstudiantesAsignacionController extends ChangeNotifier {
  EstudiantesAsignacionController(this._repository, this.asignacionId);

  final EstudianteRepository _repository;
  final int asignacionId;

  EstudiantesAsignacionState _state = EstudiantesAsignacionState.loading;
  List<EstudianteInscrito> _items = const [];
  String? _errorMessage;

  EstudiantesAsignacionState get state => _state;
  List<EstudianteInscrito> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;

  Future<void> cargar() async {
    _state = EstudiantesAsignacionState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.listarPorAsignacion(asignacionId);
      _state = _items.isEmpty
          ? EstudiantesAsignacionState.empty
          : EstudiantesAsignacionState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = EstudiantesAsignacionState.error;
    }
    notifyListeners();
  }
}
