import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/docente.dart';
import '../../domain/repositories/docente_repository.dart';

enum DocenteViewState { loading, empty, error, data }

class DocenteController extends ChangeNotifier {
  DocenteController(this._repository);

  final DocenteRepository _repository;
  DocenteViewState _state = DocenteViewState.loading;
  List<Docente> _items = const [];
  String? _errorMessage;
  bool _saving = false;
  String _busqueda = '';
  bool? _estado;

  DocenteViewState get state => _state;
  List<Docente> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  bool get saving => _saving;
  bool get hasFilters => _busqueda.isNotEmpty || _estado != null;

  Future<void> cargar({
    String? busqueda,
    bool? estado,
    bool reset = false,
  }) async {
    if (reset) {
      _busqueda = '';
      _estado = null;
    } else {
      if (busqueda != null) _busqueda = busqueda.trim();
      _estado = estado;
    }
    _state = DocenteViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.listar(
        busqueda: _busqueda,
        estado: _estado,
      );
      _state = _items.isEmpty ? DocenteViewState.empty : DocenteViewState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = DocenteViewState.error;
    }
    notifyListeners();
  }

  Future<String?> actualizar({
    required Docente docente,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
    String? direccion,
    required String sexo,
    required DateTime fechaNacimiento,
    required String especialidad,
    String? tituloProfesional,
    String? gradoAcademico,
    DateTime? fechaIncorporacion,
    String? observaciones,
  }) async {
    _saving = true;
    notifyListeners();
    try {
      await _repository.actualizar(
        id: docente.id,
        nombres: nombres,
        apellidos: apellidos,
        ci: ci,
        telefono: telefono,
        direccion: direccion,
        sexo: sexo,
        fechaNacimiento: fechaNacimiento,
        especialidad: especialidad,
        tituloProfesional: tituloProfesional,
        gradoAcademico: gradoAcademico,
        fechaIncorporacion: fechaIncorporacion,
        observaciones: observaciones,
      );
      await cargar(busqueda: _busqueda, estado: _estado);
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<String?> cambiarEstado(Docente docente) async {
    try {
      await _repository.cambiarEstado(
        id: docente.id,
        estado: !docente.estado,
      );
      await cargar(busqueda: _busqueda, estado: _estado);
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    }
  }
}
