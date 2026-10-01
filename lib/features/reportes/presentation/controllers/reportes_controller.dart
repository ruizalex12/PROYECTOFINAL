import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/reporte_academico.dart';
import '../../domain/repositories/reporte_repository.dart';
import '../../domain/services/reporte_aggregation_service.dart';
import '../../domain/services/reporte_csv_service.dart';

enum ReportesViewState { loading, empty, error, data }

class ReportesController extends ChangeNotifier {
  ReportesController(this._repository);
  final ReporteRepository _repository;

  TipoReporteAcademico tipo = TipoReporteAcademico.inscripciones;
  ReporteFilter filter = const ReporteFilter();
  ReporteOptions options = const ReporteOptions();
  ReportesViewState state = ReportesViewState.loading;
  List<Object> items = const [];
  String? errorMessage;

  bool get hasFilters => !filter.isEmpty;
  ReporteEstadoSummary get estadoSummary => ReporteAggregationService.estado(
        tipo == TipoReporteAcademico.inscripciones
            ? items.cast<ReporteInscripcionItem>().map((e) => e.estado)
            : items.cast<ReporteAsignacionItem>().map((e) => e.estado),
      );
  ReporteCalificacionSummary get calificacionSummary =>
      ReporteAggregationService.resumenCalificaciones(
          items.cast<ReporteCalificacionItem>());

  Future<void> cargar([ReporteFilter? next]) async {
    if (next != null) filter = next;
    state = ReportesViewState.loading;
    errorMessage = null;
    notifyListeners();
    try {
      options = await _repository.cargarOpciones();
      items = switch (tipo) {
        TipoReporteAcademico.inscripciones =>
          await _repository.inscripciones(filter),
        TipoReporteAcademico.asistencia => ReporteAggregationService.asistencia(
            await _repository.asistencias(filter)),
        TipoReporteAcademico.calificaciones =>
          ReporteAggregationService.calificaciones(
              await _repository.calificaciones(filter)),
        TipoReporteAcademico.asignaciones =>
          await _repository.asignaciones(filter),
      };
      state = items.isEmpty ? ReportesViewState.empty : ReportesViewState.data;
    } catch (error) {
      final mapped = ErrorMapper.message(error);
      errorMessage = mapped.contains('permisos')
          ? 'No tiene permisos para consultar esta información.'
          : mapped.contains('sesión') || mapped.contains('sesiÃ³n')
              ? mapped
              : 'No fue posible generar el reporte.';
      state = ReportesViewState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> seleccionar(TipoReporteAcademico value) async {
    tipo = value;
    filter = const ReporteFilter();
    await cargar();
  }

  Future<void> limpiarFiltros() => cargar(const ReporteFilter());
  CsvExport exportar() => ReporteCsvService.generar(tipo, items);
}
