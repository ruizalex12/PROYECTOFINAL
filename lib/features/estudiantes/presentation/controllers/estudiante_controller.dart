import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/estudiante.dart';
import '../../domain/repositories/estudiante_repository.dart';

enum EstudianteViewState { loading, empty, error, data }

class EstudianteController extends ChangeNotifier {
  EstudianteController(this._repository);

  final EstudianteRepository _repository;

  EstudianteViewState _state = EstudianteViewState.loading;
  List<Estudiante> _items = const [];
  String? _errorMessage;
  bool _saving = false;
  Estudiante? _ultimoGuardado;
  String _busqueda = '';
  bool? _estado;

  EstudianteViewState get state => _state;
  List<Estudiante> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  bool get saving => _saving;
  Estudiante? get ultimoGuardado => _ultimoGuardado;
  String get busqueda => _busqueda;
  bool? get estado => _estado;
  bool get hasFilters => _busqueda.isNotEmpty || _estado != null;

  Future<void> cargar(
      {String? busqueda, bool? estado, bool reset = false}) async {
    if (reset) {
      _busqueda = '';
      _estado = null;
    } else {
      if (busqueda != null) _busqueda = busqueda.trim();
      _estado = estado;
    }
    _state = EstudianteViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.listar(
        busqueda: _busqueda,
        estado: _estado,
      );
      _state =
          _items.isEmpty ? EstudianteViewState.empty : EstudianteViewState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = EstudianteViewState.error;
    }
    notifyListeners();
  }

  Future<String?> guardar({
    Estudiante? existente,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) async {
    _saving = true;
    _ultimoGuardado = null;
    notifyListeners();
    try {
      if (existente == null) {
        _ultimoGuardado = await _repository.crear(
          nombres: nombres,
          apellidos: apellidos,
          ci: ci,
          telefono: telefono,
        );
      } else {
        _ultimoGuardado = await _repository.actualizar(
          id: existente.id,
          nombres: nombres,
          apellidos: apellidos,
          ci: ci,
          telefono: telefono,
        );
      }
      await cargar(busqueda: _busqueda, estado: _estado);
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<String?> cambiarEstado(Estudiante estudiante) async {
    try {
      await _repository.cambiarEstado(
        id: estudiante.id,
        estado: !estudiante.estado,
      );
      await cargar(busqueda: _busqueda, estado: _estado);
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    }
  }
}
