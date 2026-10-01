import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/inscripcion.dart';
import '../../domain/repositories/inscripcion_repository.dart';

enum InscripcionViewState { loading, empty, error, data }

class InscripcionController extends ChangeNotifier {
  InscripcionController(this._repository);

  final InscripcionRepository _repository;
  InscripcionViewState _state = InscripcionViewState.loading;
  List<Inscripcion> _items = const [];
  InscripcionOptions _options = const InscripcionOptions(
    estudiantes: [],
    asignaturas: [],
    periodos: [],
  );
  String? _errorMessage;
  bool _saving = false;

  InscripcionViewState get state => _state;
  List<Inscripcion> get items => List.unmodifiable(_items);
  InscripcionOptions get options => _options;
  String? get errorMessage => _errorMessage;
  bool get saving => _saving;

  List<Inscripcion> filtrar({
    String busqueda = '',
    int? estudianteId,
    int? asignaturaId,
    int? periodoId,
    bool? estado,
  }) {
    final query = busqueda.trim().toLowerCase();
    return _items.where((item) {
      final text = [
        item.estudianteNombre,
        item.asignaturaCodigo,
        item.asignaturaNombre,
        item.periodoNombre,
      ].join(' ').toLowerCase();
      return (query.isEmpty || text.contains(query)) &&
          (estudianteId == null || item.estudianteId == estudianteId) &&
          (asignaturaId == null || item.asignaturaId == asignaturaId) &&
          (periodoId == null || item.periodoId == periodoId) &&
          (estado == null || item.estado == estado);
    }).toList(growable: false);
  }

  Future<void> cargar() async {
    _state = InscripcionViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final values = await Future.wait([
        _repository.listar(),
        _repository.cargarOpciones(),
      ]);
      _items = values[0] as List<Inscripcion>;
      _options = values[1] as InscripcionOptions;
      _state = _items.isEmpty
          ? InscripcionViewState.empty
          : InscripcionViewState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = InscripcionViewState.error;
    }
    notifyListeners();
  }

  Future<String?> guardar({
    Inscripcion? existente,
    required int estudianteId,
    required int asignaturaId,
    required int periodoId,
  }) async {
    _saving = true;
    notifyListeners();
    try {
      if (existente == null) {
        await _repository.crear(
          estudianteId: estudianteId,
          asignaturaId: asignaturaId,
          periodoId: periodoId,
        );
      } else {
        await _repository.actualizar(
          id: existente.id,
          estudianteId: estudianteId,
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

  Future<String?> cambiarEstado(Inscripcion inscripcion) async {
    try {
      await _repository.cambiarEstado(
        id: inscripcion.id,
        estado: !inscripcion.estado,
      );
      await cargar();
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    }
  }
}
