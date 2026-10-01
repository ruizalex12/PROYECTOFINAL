import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/periodo_academico.dart';
import '../../domain/repositories/periodo_academico_repository.dart';

enum PeriodoAcademicoViewState { loading, empty, error, data }

class PeriodoAcademicoController extends ChangeNotifier {
  PeriodoAcademicoController(this._repository);

  final PeriodoAcademicoRepository _repository;
  PeriodoAcademicoViewState _state = PeriodoAcademicoViewState.loading;
  List<PeriodoAcademico> _items = const [];
  String? _errorMessage;
  bool _saving = false;
  String _busqueda = '';
  bool? _estado;

  PeriodoAcademicoViewState get state => _state;
  List<PeriodoAcademico> get items => List.unmodifiable(_items);
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
    _state = PeriodoAcademicoViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.listar(
        busqueda: _busqueda,
        estado: _estado,
      );
      _state = _items.isEmpty
          ? PeriodoAcademicoViewState.empty
          : PeriodoAcademicoViewState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = PeriodoAcademicoViewState.error;
    }
    notifyListeners();
  }

  Future<String?> guardar({
    PeriodoAcademico? existente,
    required String nombre,
    required DateTime? fechaInicio,
    required DateTime? fechaFin,
  }) async {
    if (nombre.trim().isEmpty) {
      return 'Ingresa el nombre del periodo académico.';
    }
    if (fechaInicio == null) return 'Selecciona la fecha de inicio.';
    if (fechaFin == null) return 'Selecciona la fecha de finalización.';
    if (fechaFin.isBefore(fechaInicio)) {
      return 'La fecha de finalización no puede ser anterior a la fecha de inicio.';
    }
    _saving = true;
    notifyListeners();
    try {
      if (existente == null) {
        await _repository.crear(
          nombre: nombre,
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
        );
      } else {
        await _repository.actualizar(
          id: existente.id,
          nombre: nombre,
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
        );
      }
      await cargar(busqueda: _busqueda, estado: _estado);
      return null;
    } on AppException catch (error) {
      return error.message;
    } catch (error) {
      return ErrorMapper.message(error);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<String?> cambiarEstado(PeriodoAcademico periodo) async {
    try {
      await _repository.cambiarEstado(
        id: periodo.id,
        estado: !periodo.estado,
      );
      await cargar(busqueda: _busqueda, estado: _estado);
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    }
  }
}
