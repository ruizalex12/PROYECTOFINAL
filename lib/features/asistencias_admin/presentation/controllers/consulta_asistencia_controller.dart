import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../asistencia/domain/entities/asistencia.dart';
import '../../domain/entities/consulta_asistencia.dart';
import '../../domain/repositories/consulta_asistencia_repository.dart';

enum ConsultaAsistenciaViewState { loading, empty, error, data }

class ConsultaAsistenciaController extends ChangeNotifier {
  ConsultaAsistenciaController(this._repository);

  final ConsultaAsistenciaRepository _repository;
  ConsultaAsistenciaViewState _state = ConsultaAsistenciaViewState.loading;
  List<ConsultaAsistencia> _items = const [];
  AsistenciaAdminOptions _options = const AsistenciaAdminOptions(
    periodos: [],
    asignaturas: [],
    docentes: [],
  );
  AsistenciaAdminFilter _filter = const AsistenciaAdminFilter();
  AsistenciaAdminSummary _summary = const AsistenciaAdminSummary.empty();
  String? _errorMessage;

  ConsultaAsistenciaViewState get state => _state;
  List<ConsultaAsistencia> get items => List.unmodifiable(_items);
  AsistenciaAdminOptions get options => _options;
  AsistenciaAdminFilter get filter => _filter;
  AsistenciaAdminSummary get summary => _summary;
  String? get errorMessage => _errorMessage;
  bool get hasFilters => !_filter.isEmpty;

  Future<void> cargar([AsistenciaAdminFilter? filter]) async {
    if (filter != null) _filter = filter;
    _state = ConsultaAsistenciaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.listar(_filter),
        _repository.cargarOpciones(),
      ]);
      _items = results[0] as List<ConsultaAsistencia>;
      _options = results[1] as AsistenciaAdminOptions;
      _summary = AsistenciaAdminSummary.fromItems(_items);
      _state = _items.isEmpty
          ? ConsultaAsistenciaViewState.empty
          : ConsultaAsistenciaViewState.data;
    } catch (error) {
      final mapped = ErrorMapper.message(error);
      _errorMessage =
          mapped == 'No tiene permisos para realizar esta operación.'
              ? 'No tiene permisos para consultar esta información.'
              : mapped == 'Su sesión no es válida o ha expirado.'
                  ? mapped
                  : 'No fue posible cargar los registros de asistencia.';
      _state = ConsultaAsistenciaViewState.error;
    }
    notifyListeners();
  }

  Future<void> limpiarFiltros() => cargar(const AsistenciaAdminFilter());

  AsistenciaAdminFilter crearFiltro({
    String busqueda = '',
    int? periodoId,
    int? asignaturaId,
    String? docenteId,
    EstadoAsistencia? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) =>
      AsistenciaAdminFilter(
        busqueda: busqueda,
        periodoId: periodoId,
        asignaturaId: asignaturaId,
        docenteId: docenteId,
        estado: estado,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
}
