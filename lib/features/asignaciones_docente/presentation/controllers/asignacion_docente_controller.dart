import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/asignacion_docente.dart';
import '../../domain/repositories/asignacion_docente_repository.dart';

enum AsignacionDocenteViewState { loading, empty, error, data }

class AsignacionDocenteController extends ChangeNotifier {
  AsignacionDocenteController(this._repository);

  final AsignacionDocenteRepository _repository;

  AsignacionDocenteViewState _state = AsignacionDocenteViewState.loading;
  List<AsignacionDocente> _items = const [];
  AsignacionDocenteOptions _options = const AsignacionDocenteOptions(
    docentes: [],
    asignaturas: [],
    periodos: [],
  );
  String? _errorMessage;
  bool _saving = false;

  AsignacionDocenteViewState get state => _state;
  List<AsignacionDocente> get items => List.unmodifiable(_items);
  AsignacionDocenteOptions get options => _options;
  String? get errorMessage => _errorMessage;
  bool get saving => _saving;

  Future<void> cargar() async {
    _state = AsignacionDocenteViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.listar(),
        _repository.cargarOpciones(),
      ]);
      _items = results[0] as List<AsignacionDocente>;
      _options = results[1] as AsignacionDocenteOptions;
      _state = _items.isEmpty
          ? AsignacionDocenteViewState.empty
          : AsignacionDocenteViewState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = AsignacionDocenteViewState.error;
    }
    notifyListeners();
  }

  Future<String?> guardar({
    AsignacionDocente? existente,
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  }) async {
    _saving = true;
    notifyListeners();
    try {
      if (existente == null) {
        await _repository.crear(
          docenteId: docenteId,
          asignaturaId: asignaturaId,
          periodoId: periodoId,
        );
      } else {
        await _repository.actualizar(
          id: existente.id,
          docenteId: docenteId,
          asignaturaId: asignaturaId,
          periodoId: periodoId,
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

  Future<String?> cambiarEstado(AsignacionDocente asignacion) async {
    try {
      await _repository.cambiarEstado(
        id: asignacion.id,
        estado: !asignacion.estado,
      );
      await cargar();
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    }
  }
}
