import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/asistencias_admin/domain/entities/consulta_asistencia.dart';
import 'package:proyecto_final_360/features/calificaciones_admin/domain/entities/consulta_calificacion.dart';
import 'package:proyecto_final_360/features/reportes/domain/entities/reporte_academico.dart';
import 'package:proyecto_final_360/features/reportes/domain/repositories/reporte_repository.dart';
import 'package:proyecto_final_360/features/reportes/presentation/controllers/reportes_controller.dart';

void main() {
  late _FakeRepository repository;
  late ReportesController controller;
  setUp(() {
    repository = _FakeRepository();
    controller = ReportesController(repository);
  });

  test('carga inicial lista inscripciones y resumen', () async {
    await controller.cargar();
    expect(controller.state, ReportesViewState.data);
    expect(controller.items, hasLength(2));
    expect(controller.estadoSummary.activos, 1);
    expect(controller.estadoSummary.inactivos, 1);
  });

  test('pasa filtros combinados al repositorio', () async {
    const filter = ReporteFilter(
        periodoId: 1, asignaturaId: 2, estudianteId: 3, estado: true);
    await controller.cargar(filter);
    expect(repository.lastFilter, same(filter));
    expect(controller.hasFilters, isTrue);
  });

  test('cambia entre los cuatro tipos de reporte', () async {
    for (final type in TipoReporteAcademico.values) {
      await controller.seleccionar(type);
      expect(controller.tipo, type);
    }
  });

  test('limpiar filtros restaura filtro vacío', () async {
    await controller.cargar(const ReporteFilter(periodoId: 1));
    await controller.limpiarFiltros();
    expect(controller.filter.isEmpty, isTrue);
  });

  test('estado vacío usa empty', () async {
    repository.inscriptionItems = [];
    await controller.cargar();
    expect(controller.state, ReportesViewState.empty);
  });

  test('error datasource muestra mensaje general', () async {
    repository.failure = Exception('boom');
    await controller.cargar();
    expect(controller.state, ReportesViewState.error);
    expect(controller.errorMessage, 'No fue posible generar el reporte.');
  });

  test('repositorio de Reportes solo declara operaciones SELECT', () {
    expect(ReporteRepository, isNotNull);
    expect(repository, isA<ReporteRepository>());
  });
}

class _FakeRepository implements ReporteRepository {
  Object? failure;
  ReporteFilter? lastFilter;
  List<ReporteInscripcionItem> inscriptionItems = [
    ReporteInscripcionItem(
        id: 1,
        estudianteId: 1,
        estudiante: 'Ana',
        codigo: 'E1',
        ci: '1',
        asignatura: 'A',
        periodo: 'P',
        fecha: DateTime(2026),
        estado: true),
    ReporteInscripcionItem(
        id: 2,
        estudianteId: 2,
        estudiante: 'Beto',
        codigo: 'E2',
        ci: '2',
        asignatura: 'A',
        periodo: 'P',
        fecha: DateTime(2026),
        estado: false),
  ];
  void _check(ReporteFilter filter) {
    if (failure != null) throw failure!;
    lastFilter = filter;
  }

  @override
  Future<ReporteOptions> cargarOpciones() async {
    if (failure != null) throw failure!;
    return const ReporteOptions();
  }

  @override
  Future<List<ReporteInscripcionItem>> inscripciones(
      ReporteFilter filter) async {
    _check(filter);
    return inscriptionItems;
  }

  @override
  Future<List<ConsultaAsistencia>> asistencias(ReporteFilter filter) async {
    _check(filter);
    return [];
  }

  @override
  Future<List<ConsultaCalificacion>> calificaciones(
      ReporteFilter filter) async {
    _check(filter);
    return [];
  }

  @override
  Future<List<ReporteAsignacionItem>> asignaciones(ReporteFilter filter) async {
    _check(filter);
    return [];
  }
}
