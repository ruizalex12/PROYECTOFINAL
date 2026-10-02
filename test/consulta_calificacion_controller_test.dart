import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/calificaciones/domain/entities/calificacion.dart';
import 'package:proyecto_final_360/features/calificaciones_admin/domain/entities/consulta_calificacion.dart';
import 'package:proyecto_final_360/features/calificaciones_admin/domain/repositories/consulta_calificacion_repository.dart';
import 'package:proyecto_final_360/features/calificaciones_admin/presentation/controllers/consulta_calificacion_controller.dart';

void main() {
  test('carga inicial comienza en loading', () {
    expect(_controller().state, ConsultaCalificacionViewState.loading);
  });
  test('lista calificaciones', () async {
    final c = _controller();
    await c.cargar();
    expect(c.state, ConsultaCalificacionViewState.data);
    expect(c.items, hasLength(3));
  });
  test('representa lista vacía', () async {
    final c = _controller(items: []);
    await c.cargar();
    expect(c.state, ConsultaCalificacionViewState.empty);
  });
  test('busca por datos relacionados y tipo', () async {
    final cases = <String, ConsultaCalificacion>{
      'Ana': _alta,
      'CI-1': _alta,
      'EST-1': _alta,
      'Historia': _media,
      'Pedro': _media,
      'Final': _media,
    };
    for (final entry in cases.entries) {
      final c = _controller();
      await c.cargar(CalificacionAdminFilter(busqueda: entry.key));
      expect(c.items, [entry.value]);
    }
  });
  test('filtra periodo', () async {
    final c = _controller();
    await c.cargar(const CalificacionAdminFilter(periodoId: 10));
    expect(c.items, [_alta, _baja]);
  });
  test('filtra asignatura', () async {
    final c = _controller();
    await c.cargar(const CalificacionAdminFilter(asignaturaId: 20));
    expect(c.items, [_media]);
  });
  test('filtra docente', () async {
    final c = _controller();
    await c.cargar(const CalificacionAdminFilter(docenteId: 'doc-2'));
    expect(c.items, [_media]);
  });
  test('filtra tipo evaluación', () async {
    final c = _controller();
    await c.cargar(const CalificacionAdminFilter(tipoEvaluacion: 'Final'));
    expect(c.items, [_media]);
  });
  test('filtra nota mínima', () async {
    final c = _controller();
    await c.cargar(const CalificacionAdminFilter(notaMinima: 80));
    expect(c.items, [_alta]);
  });
  test('filtra nota máxima', () async {
    final c = _controller();
    await c.cargar(const CalificacionAdminFilter(notaMaxima: 60));
    expect(c.items, [_baja]);
  });
  test('filtra rango de notas inclusivo', () async {
    final c = _controller();
    await c
        .cargar(const CalificacionAdminFilter(notaMinima: 60, notaMaxima: 80));
    expect(c.items, [_media]);
  });
  test('rechaza nota mínima mayor a máxima', () async {
    final c = _controller();
    final error = await c
        .cargar(const CalificacionAdminFilter(notaMinima: 90, notaMaxima: 50));
    expect(error, 'La nota mínima no puede ser mayor que la nota máxima.');
  });
  test('combina filtros', () async {
    final c = _controller();
    await c.cargar(const CalificacionAdminFilter(
      periodoId: 10,
      asignaturaId: 10,
      docenteId: 'doc-1',
      tipoEvaluacion: 'Parcial',
      notaMinima: 90,
      notaMaxima: 100,
    ));
    expect(c.items, [_alta]);
  });
  test('limpia filtros', () async {
    final c = _controller();
    await c.cargar(const CalificacionAdminFilter(notaMinima: 90));
    await c.limpiarFiltros();
    expect(c.filter.isEmpty, isTrue);
    expect(c.items, hasLength(3));
  });
  test('calcula total', () async {
    final c = _controller();
    await c.cargar();
    expect(c.summary.total, 3);
  });
  test('calcula promedio', () async {
    final c = _controller();
    await c.cargar();
    expect(c.summary.promedio, closeTo(70, .001));
  });
  test('calcula nota mínima resumen', () async {
    final c = _controller();
    await c.cargar();
    expect(c.summary.notaMinima, 50);
  });
  test('calcula nota máxima resumen', () async {
    final c = _controller();
    await c.cargar();
    expect(c.summary.notaMaxima, 95);
  });
  test('maneja error datasource', () async {
    final c = ConsultaCalificacionController(_ErrorRepository());
    await c.cargar();
    expect(c.state, ConsultaCalificacionViewState.error);
    expect(c.errorMessage, 'No fue posible cargar las calificaciones.');
  });
  test('mantiene escala 0 a 100', () {
    expect(CalificacionRules.notaValida(0), isTrue);
    expect(CalificacionRules.notaValida(100), isTrue);
    expect(CalificacionRules.notaValida(-.01), isFalse);
    expect(CalificacionRules.notaValida(100.01), isFalse);
    expect(
      CalificacionAdminFilterRules.validar(notaMinima: 0, notaMaxima: 100),
      isNull,
    );
  });
}

ConsultaCalificacionController _controller(
        {List<ConsultaCalificacion>? items}) =>
    ConsultaCalificacionController(_FakeRepository(items ?? _items));

final _alta = ConsultaCalificacion(
  id: 1,
  fechaRegistro: DateTime(2026, 9, 3),
  tipoEvaluacion: 'Parcial',
  nota: 95,
  estudianteId: 1,
  estudianteCodigo: 'EST-1',
  estudianteNombre: 'Ana Flores',
  estudianteCi: 'CI-1',
  asignaturaId: 10,
  asignaturaNombre: 'Teología',
  periodoId: 10,
  periodoNombre: '2026-II',
  docenteId: 'doc-1',
  docenteNombre: 'Laura Ríos',
);
final _baja = ConsultaCalificacion(
  id: 2,
  fechaRegistro: DateTime(2026, 9, 2),
  tipoEvaluacion: 'Parcial',
  nota: 50,
  estudianteId: 2,
  estudianteNombre: 'Luis Pérez',
  estudianteCi: 'CI-2',
  asignaturaId: 10,
  asignaturaNombre: 'Teología',
  periodoId: 10,
  periodoNombre: '2026-II',
  docenteId: 'doc-1',
  docenteNombre: 'Laura Ríos',
);
final _media = ConsultaCalificacion(
  id: 3,
  fechaRegistro: DateTime(2026, 9, 1),
  tipoEvaluacion: 'Final',
  nota: 65,
  estudianteId: 3,
  estudianteNombre: 'Marta López',
  estudianteCi: 'CI-3',
  asignaturaId: 20,
  asignaturaNombre: 'Historia',
  periodoId: 20,
  periodoNombre: '2027-I',
  docenteId: 'doc-2',
  docenteNombre: 'Pedro Díaz',
);
final _items = [_alta, _baja, _media];

class _FakeRepository implements ConsultaCalificacionRepository {
  _FakeRepository(this.source);
  final List<ConsultaCalificacion> source;

  @override
  Future<List<ConsultaCalificacion>> listar(CalificacionAdminFilter f) async {
    final search = f.busqueda.toLowerCase();
    return source.where((item) {
      final text = [
        item.estudianteNombre,
        item.estudianteCi,
        item.estudianteCodigo ?? '',
        item.asignaturaNombre,
        item.docenteNombre,
        item.tipoEvaluacion,
      ].join(' ').toLowerCase();
      return (search.isEmpty || text.contains(search)) &&
          (f.periodoId == null || item.periodoId == f.periodoId) &&
          (f.asignaturaId == null || item.asignaturaId == f.asignaturaId) &&
          (f.docenteId == null || item.docenteId == f.docenteId) &&
          (f.tipoEvaluacion == null ||
              item.tipoEvaluacion == f.tipoEvaluacion) &&
          (f.notaMinima == null || item.nota >= f.notaMinima!) &&
          (f.notaMaxima == null || item.nota <= f.notaMaxima!);
    }).toList(growable: false);
  }

  @override
  Future<CalificacionAdminOptions> cargarOpciones() async =>
      const CalificacionAdminOptions(
        periodos: [],
        asignaturas: [],
        docentes: [],
        tiposEvaluacion: [],
      );
}

class _ErrorRepository extends _FakeRepository {
  _ErrorRepository() : super(const []);
  @override
  Future<List<ConsultaCalificacion>> listar(CalificacionAdminFilter filter) =>
      throw Exception('Failed to fetch');
}
