import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/asignatura.dart';
import '../../domain/repositories/asignatura_repository.dart';

enum AsignaturaViewState { loading, empty, error, data }

class AsignaturaController extends ChangeNotifier {
  AsignaturaController(this._repository);

  final AsignaturaRepository _repository;

  AsignaturaViewState _state = AsignaturaViewState.loading;
  List<Asignatura> _items = const [];
  String? _errorMessage;
  bool _saving = false;

  AsignaturaViewState get state => _state;
  List<Asignatura> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  bool get saving => _saving;

  Future<void> cargar() async {
    _state = AsignaturaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.listar();
      _state =
          _items.isEmpty ? AsignaturaViewState.empty : AsignaturaViewState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = AsignaturaViewState.error;
    }
    notifyListeners();
  }

  Future<String?> guardar({
    Asignatura? existente,
    required String codigo,
    required String nombre,
    String? descripcion,
  }) async {
    _saving = true;
    notifyListeners();
    try {
      if (existente == null) {
        await _repository.crear(
          codigo: codigo,
          nombre: nombre,
          descripcion: descripcion,
        );
      } else {
        await _repository.actualizar(
          id: existente.id,
          codigo: codigo,
          nombre: nombre,
          descripcion: descripcion,
        );
      }
      await cargar();
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<String?> cambiarEstado(Asignatura asignatura) async {
    try {
      await _repository.cambiarEstado(
        id: asignatura.id,
        estado: !asignatura.estado,
      );
      await cargar();
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    }
  }
}
