import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/asistencia/domain/entities/asistencia.dart';
import 'package:proyecto_final_360/features/asistencias_admin/domain/entities/consulta_asistencia.dart';
import 'package:proyecto_final_360/features/asistencias_admin/domain/repositories/consulta_asistencia_repository.dart';
import 'package:proyecto_final_360/features/asistencias_admin/presentation/controllers/consulta_asistencia_controller.dart';

void main() {
  test('carga inicial comienza en loading', () {
    expect(_controller().state, ConsultaAsistenciaViewState.loading);
  });

  test('lista registros de asistencia', () async {
    final controller = _controller();
    await controller.cargar();
    expect(controller.state, ConsultaAsistenciaViewState.data);
    expect(controller.items, hasLength(3));
  });

  test('representa lista vacía', () async {
    final controller = _controller(items: []);
    await controller.cargar();
    expect(controller.state, ConsultaAsistenciaViewState.empty);
  });

  test('busca por estudiante, CI, código, asignatura y docente', () async {
    final cases = <String, List<ConsultaAsistencia>>{
      'Ana': [_presente],
      'CI-1': [_presente],
      'EST-1': [_presente],
      'Historia': [_licencia],
      'Pedro': [_licencia],
    };
    for (final entry in cases.entries) {
      final controller = _controller();
      await controller.cargar(AsistenciaAdminFilter(busqueda: entry.key));
      expect(controller.items, entry.value);
    }
  });

  test('filtra por periodo', () async {
    final controller = _controller();
    await controller.cargar(const AsistenciaAdminFilter(periodoId: 10));
    expect(controller.items, [_presente, _ausente]);
  });

  test('filtra por asignatura', () async {
    final controller = _controller();
    await controller.cargar(const AsistenciaAdminFilter(asignaturaId: 20));
    expect(controller.items, [_licencia]);
  });

  test('filtra por docente', () async {
    final controller = _controller();
    await controller.cargar(const AsistenciaAdminFilter(docenteId: 'doc-2'));
    expect(controller.items, [_licencia]);
  });

  test('filtra PRESENTE', () async {
    final controller = _controller();
    await controller.cargar(
      const AsistenciaAdminFilter(estado: EstadoAsistencia.presente),
    );
    expect(controller.items, [_presente]);
  });

  test('filtra AUSENTE', () async {
    final controller = _controller();
    await controller.cargar(
      const AsistenciaAdminFilter(estado: EstadoAsistencia.ausente),
    );
    expect(controller.items, [_ausente]);
  });

  test('filtra LICENCIA', () async {
    final controller = _controller();
    await controller.cargar(
      const AsistenciaAdminFilter(estado: EstadoAsistencia.licencia),
    );
    expect(controller.items, [_licencia]);
  });

  test('filtra rango de fechas inclusivo', () async {
    final controller = _controller();
    await controller.cargar(AsistenciaAdminFilter(
      fechaDesde: DateTime(2026, 9, 2),
      fechaHasta: DateTime(2026, 9, 3),
    ));
    expect(controller.items, [_ausente, _licencia]);
  });

  test('combina filtros', () async {
    final controller = _controller();
    await controller.cargar(AsistenciaAdminFilter(
      periodoId: 10,
      asignaturaId: 10,
      docenteId: 'doc-1',
      estado: EstadoAsistencia.ausente,
      fechaDesde: DateTime(2026, 9, 1),
      fechaHasta: DateTime(2026, 9, 2),
    ));
    expect(controller.items, [_ausente]);
  });

  test('limpia todos los filtros', () async {
    final controller = _controller();
    await controller.cargar(
      const AsistenciaAdminFilter(estado: EstadoAsistencia.ausente),
    );
    await controller.limpiarFiltros();
    expect(controller.filter.isEmpty, isTrue);
    expect(controller.items, hasLength(3));
  });

  test('calcula total', () async {
    final controller = _controller();
    await controller.cargar();
    expect(controller.summary.total, 3);
  });

  test('calcula presentes', () async {
    final controller = _controller();
    await controller.cargar();
    expect(controller.summary.presentes, 1);
  });

  test('calcula ausentes', () async {
    final controller = _controller();
    await controller.cargar();
    expect(controller.summary.ausentes, 1);
  });

  test('calcula licencias', () async {
    final controller = _controller();
    await controller.cargar();
    expect(controller.summary.licencias, 1);
  });

  test('maneja error del datasource', () async {
    final controller = ConsultaAsistenciaController(_ErrorRepository());
    await controller.cargar();
    expect(controller.state, ConsultaAsistenciaViewState.error);
    expect(controller.errorMessage,
        'No fue posible cargar los registros de asistencia.');
  });
}

ConsultaAsistenciaController _controller({List<ConsultaAsistencia>? items}) =>
    ConsultaAsistenciaController(_FakeRepository(items ?? _items));

final _presente = ConsultaAsistencia(
  id: 1,
  fecha: DateTime(2026, 9, 1),
  fechaRegistro: DateTime(2026, 9, 1, 10),
  estado: EstadoAsistencia.presente,
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

final _ausente = ConsultaAsistencia(
  id: 2,
  fecha: DateTime(2026, 9, 2),
  fechaRegistro: DateTime(2026, 9, 2, 10),
  estado: EstadoAsistencia.ausente,
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

final _licencia = ConsultaAsistencia(
  id: 3,
  fecha: DateTime(2026, 9, 3),
  fechaRegistro: DateTime(2026, 9, 3, 10),
  estado: EstadoAsistencia.licencia,
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

final _items = [_presente, _ausente, _licencia];

class _FakeRepository implements ConsultaAsistenciaRepository {
  _FakeRepository(this.source);

  final List<ConsultaAsistencia> source;

  @override
  Future<List<ConsultaAsistencia>> listar(AsistenciaAdminFilter filter) async {
    final search = filter.busqueda.toLowerCase();
    return source.where((item) {
      final date = DateTime(item.fecha.year, item.fecha.month, item.fecha.day);
      final text = [
        item.estudianteNombre,
        item.estudianteCi,
        item.estudianteCodigo ?? '',
        item.asignaturaNombre,
        item.docenteNombre,
      ].join(' ').toLowerCase();
      return (search.isEmpty || text.contains(search)) &&
          (filter.periodoId == null || item.periodoId == filter.periodoId) &&
          (filter.asignaturaId == null ||
              item.asignaturaId == filter.asignaturaId) &&
          (filter.docenteId == null || item.docenteId == filter.docenteId) &&
          (filter.estado == null || item.estado == filter.estado) &&
          (filter.fechaDesde == null || !date.isBefore(filter.fechaDesde!)) &&
          (filter.fechaHasta == null || !date.isAfter(filter.fechaHasta!));
    }).toList(growable: false);
  }

  @override
  Future<AsistenciaAdminOptions> cargarOpciones() async =>
      const AsistenciaAdminOptions(
        periodos: [],
        asignaturas: [],
        docentes: [],
      );
}

class _ErrorRepository extends _FakeRepository {
  _ErrorRepository() : super(const []);

  @override
  Future<List<ConsultaAsistencia>> listar(AsistenciaAdminFilter filter) =>
      throw Exception('Failed to fetch');
}
