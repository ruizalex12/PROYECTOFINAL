import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/consulta_calificacion.dart';
import '../../domain/repositories/consulta_calificacion_repository.dart';

enum ConsultaCalificacionViewState { loading, empty, error, data }

class ConsultaCalificacionController extends ChangeNotifier {
  ConsultaCalificacionController(this._repository);
  final ConsultaCalificacionRepository _repository;

  ConsultaCalificacionViewState _state = ConsultaCalificacionViewState.loading;
  List<ConsultaCalificacion> _items = const [];
  CalificacionAdminOptions _options = const CalificacionAdminOptions(
    periodos: [],
    asignaturas: [],
    docentes: [],
    tiposEvaluacion: [],
  );
  CalificacionAdminFilter _filter = const CalificacionAdminFilter();
  CalificacionAdminSummary _summary = const CalificacionAdminSummary.empty();
  String? _errorMessage;

  ConsultaCalificacionViewState get state => _state;
  List<ConsultaCalificacion> get items => List.unmodifiable(_items);
  CalificacionAdminOptions get options => _options;
  CalificacionAdminFilter get filter => _filter;
  CalificacionAdminSummary get summary => _summary;
  String? get errorMessage => _errorMessage;
  bool get hasFilters => !_filter.isEmpty;

  Future<String?> cargar([CalificacionAdminFilter? filter]) async {
    if (filter != null) {
      final validation = CalificacionAdminFilterRules.validar(
        notaMinima: filter.notaMinima,
        notaMaxima: filter.notaMaxima,
      );
      if (validation != null) return validation;
      _filter = filter;
    }
    _state = ConsultaCalificacionViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.listar(_filter),
        _repository.cargarOpciones(),
      ]);
      _items = results[0] as List<ConsultaCalificacion>;
      _options = results[1] as CalificacionAdminOptions;
      _summary = CalificacionAdminSummary.fromItems(_items);
      _state = _items.isEmpty
          ? ConsultaCalificacionViewState.empty
          : ConsultaCalificacionViewState.data;
      return null;
    } catch (error) {
      final mapped = ErrorMapper.message(error);
      _errorMessage =
          mapped == 'No tiene permisos para realizar esta operación.'
              ? 'No tiene permisos para consultar esta información.'
              : mapped == 'Su sesión no es válida o ha expirado.'
                  ? mapped
                  : 'No fue posible cargar las calificaciones.';
      _state = ConsultaCalificacionViewState.error;
      return _errorMessage;
    } finally {
      notifyListeners();
    }
  }

  Future<String?> limpiarFiltros() => cargar(const CalificacionAdminFilter());
}
