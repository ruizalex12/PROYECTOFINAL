import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../estudiantes/domain/entities/estudiante_inscrito.dart';
import '../../../estudiantes/domain/repositories/estudiante_repository.dart';
import '../../domain/entities/asistencia.dart';
import '../../domain/repositories/asistencia_repository.dart';

enum AsistenciaViewState { loading, empty, error, data }

class AsistenciaBorrador {
  const AsistenciaBorrador({
    required this.estudiante,
    required this.estado,
    this.observacion,
  });

  final EstudianteInscrito estudiante;
  final EstadoAsistencia estado;
  final String? observacion;

  AsistenciaBorrador copyWith({
    EstadoAsistencia? estado,
    String? observacion,
  }) =>
      AsistenciaBorrador(
        estudiante: estudiante,
        estado: estado ?? this.estado,
        observacion: observacion ?? this.observacion,
      );
}

class AsistenciaController extends ChangeNotifier {
  AsistenciaController(
    this._asistencias,
    this._estudiantes,
    this.asignacionId, {
    DateTime? fechaInicial,
  }) : _fecha = _onlyDate(fechaInicial ?? DateTime.now());

  final AsistenciaRepository _asistencias;
  final EstudianteRepository _estudiantes;
  final int asignacionId;

  DateTime _fecha;
  AsistenciaViewState _state = AsistenciaViewState.loading;
  List<AsistenciaBorrador> _items = const [];
  String? _errorMessage;
  bool _saving = false;

  DateTime get fecha => _fecha;
  AsistenciaViewState get state => _state;
  List<AsistenciaBorrador> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  bool get saving => _saving;

  Future<void> cambiarFecha(DateTime value) async {
    _fecha = _onlyDate(value);
    await cargar();
  }

  Future<void> cargar() async {
    _state = AsistenciaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _estudiantes.listarPorAsignacion(asignacionId),
        _asistencias.listarPorFecha(
          asignacionId: asignacionId,
          fecha: _fecha,
        ),
      ]);
      final estudiantes = results[0] as List<EstudianteInscrito>;
      final registros = results[1] as List<Asistencia>;
      final porInscripcion = {
        for (final item in registros) item.inscripcionId: item,
      };
      _items = estudiantes.map((estudiante) {
        final saved = porInscripcion[estudiante.inscripcionId];
        return AsistenciaBorrador(
          estudiante: estudiante,
          estado: saved?.estado ?? EstadoAsistencia.presente,
          observacion: saved?.observacion,
        );
      }).toList(growable: false);
      _state =
          _items.isEmpty ? AsistenciaViewState.empty : AsistenciaViewState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = AsistenciaViewState.error;
    }
    notifyListeners();
  }

  void cambiarEstado(int index, EstadoAsistencia value) {
    _replace(index, _items[index].copyWith(estado: value));
  }

  void cambiarObservacion(int index, String value) {
    _replace(index, _items[index].copyWith(observacion: value));
  }

  Future<String?> guardar() async {
    if (_items.isEmpty) return 'No hay estudiantes para registrar.';
    _saving = true;
    notifyListeners();
    try {
      await _asistencias.guardarTodos(
        _items
            .map(
              (item) => Asistencia(
                inscripcionId: item.estudiante.inscripcionId,
                asignacionDocenteId: asignacionId,
                fecha: _fecha,
                estado: item.estado,
                observacion: item.observacion,
              ),
            )
            .toList(growable: false),
      );
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  void _replace(int index, AsistenciaBorrador value) {
    final updated = [..._items];
    updated[index] = value;
    _items = updated;
    notifyListeners();
  }

  static DateTime _onlyDate(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
