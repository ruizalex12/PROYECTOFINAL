import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/asignacion_docente.dart';
import '../../domain/repositories/asignacion_docente_repository.dart';

enum MisAsignaturasState { loading, empty, error, data }

class MisAsignaturasController extends ChangeNotifier {
  MisAsignaturasController(this._repository);

  final AsignacionDocenteRepository _repository;

  MisAsignaturasState _state = MisAsignaturasState.loading;
  List<AsignacionDocente> _items = const [];
  String? _errorMessage;

  MisAsignaturasState get state => _state;
  List<AsignacionDocente> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;

  Future<void> cargar() async {
    _state = MisAsignaturasState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.listarPropiasActivas();
      _state =
          _items.isEmpty ? MisAsignaturasState.empty : MisAsignaturasState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = MisAsignaturasState.error;
    }
    notifyListeners();
  }
}
