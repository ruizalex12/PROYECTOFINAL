import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/core/errors/app_exception.dart';
import 'package:proyecto_final_360/features/periodos/domain/entities/periodo_academico.dart';
import 'package:proyecto_final_360/features/periodos/domain/repositories/periodo_academico_repository.dart';
import 'package:proyecto_final_360/features/periodos/presentation/controllers/periodo_academico_controller.dart';

void main() {
  test('estado inicial loading', () {
    expect(
      PeriodoAcademicoController(_FakeRepository()).state,
      PeriodoAcademicoViewState.loading,
    );
  });

  test('representa lista vacía', () async {
    final controller = PeriodoAcademicoController(_FakeRepository(items: []));
    await controller.cargar();
    expect(controller.state, PeriodoAcademicoViewState.empty);
  });

  test('representa error de carga', () async {
    final controller = PeriodoAcademicoController(_ErrorRepository());
    await controller.cargar();
    expect(controller.state, PeriodoAcademicoViewState.error);
    expect(
        controller.errorMessage, 'No fue posible conectarse con el servidor.');
  });

  test('lista periodos con datos', () async {
    final controller = PeriodoAcademicoController(_FakeRepository());
    await controller.cargar();
    expect(controller.state, PeriodoAcademicoViewState.data);
    expect(controller.items.first.nombre, 'Gestión 2026');
  });

  test('registra periodo correctamente', () async {
    final repository = _FakeRepository(items: []);
    final controller = PeriodoAcademicoController(repository);
    final error = await controller.guardar(
      nombre: 'Gestión 2027',
      fechaInicio: DateTime(2027, 1, 1),
      fechaFin: DateTime(2027, 12, 31),
    );
    expect(error, isNull);
    expect(repository.created, isTrue);
  });

  test('rechaza nombre duplicado', () async {
    final controller = PeriodoAcademicoController(_DuplicateRepository());
    final error = await controller.guardar(
      nombre: 'Gestión 2026',
      fechaInicio: DateTime(2026, 1, 1),
      fechaFin: DateTime(2026, 12, 31),
    );
    expect(error, 'Ya existe un periodo académico con este nombre.');
  });

  test('rechaza nombre vacío', () async {
    final controller = PeriodoAcademicoController(_FakeRepository());
    final error = await controller.guardar(
      nombre: '  ',
      fechaInicio: DateTime(2026, 1, 1),
      fechaFin: DateTime(2026, 12, 31),
    );
    expect(error, 'Ingresa el nombre del periodo académico.');
  });

  test('rechaza fecha final anterior a fecha inicial', () async {
    final controller = PeriodoAcademicoController(_FakeRepository());
    final error = await controller.guardar(
      nombre: 'Gestión 2027',
      fechaInicio: DateTime(2027, 12, 31),
      fechaFin: DateTime(2027, 1, 1),
    );
    expect(
      error,
      'La fecha de finalización no puede ser anterior a la fecha de inicio.',
    );
  });

  test('actualiza periodo', () async {
    final repository = _FakeRepository();
    final controller = PeriodoAcademicoController(repository);
    final error = await controller.guardar(
      existente: _activo,
      nombre: 'Gestión 2026 actualizada',
      fechaInicio: DateTime(2026, 1, 1),
      fechaFin: DateTime(2026, 11, 30),
    );
    expect(error, isNull);
    expect(repository.updated, isTrue);
  });

  test('desactiva periodo', () async {
    final repository = _FakeRepository();
    final controller = PeriodoAcademicoController(repository);
    await controller.cambiarEstado(_activo);
    expect(repository.lastState, isFalse);
  });

  test('reactiva periodo', () async {
    final repository = _FakeRepository();
    final controller = PeriodoAcademicoController(repository);
    await controller.cambiarEstado(_inactivo);
    expect(repository.lastState, isTrue);
  });

  test('filtra periodos activos', () async {
    final controller = PeriodoAcademicoController(_FakeRepository());
    await controller.cargar(estado: true);
    expect(controller.items.every((item) => item.estado), isTrue);
  });

  test('filtra periodos inactivos', () async {
    final controller = PeriodoAcademicoController(_FakeRepository());
    await controller.cargar(estado: false);
    expect(controller.items.single.estado, isFalse);
  });

  test('busca periodo por nombre', () async {
    final controller = PeriodoAcademicoController(_FakeRepository());
    await controller.cargar(busqueda: '2025');
    expect(controller.items.single.nombre, 'Gestión 2025');
  });
}

final _activo = PeriodoAcademico(
  id: 1,
  nombre: 'Gestión 2026',
  fechaInicio: DateTime(2026, 1, 1),
  fechaFin: DateTime(2026, 12, 31),
  estado: true,
);

final _inactivo = PeriodoAcademico(
  id: 2,
  nombre: 'Gestión 2025',
  fechaInicio: DateTime(2025, 1, 1),
  fechaFin: DateTime(2025, 12, 31),
  estado: false,
);

class _FakeRepository implements PeriodoAcademicoRepository {
  _FakeRepository({List<PeriodoAcademico>? items})
      : items = items ?? [_activo, _inactivo];

  List<PeriodoAcademico> items;
  bool created = false;
  bool updated = false;
  bool? lastState;

  @override
  Future<List<PeriodoAcademico>> listar(
      {String? busqueda, bool? estado}) async {
    final query = busqueda?.trim().toLowerCase() ?? '';
    return items
        .where(
          (item) =>
              (estado == null || item.estado == estado) &&
              (query.isEmpty || item.nombre.toLowerCase().contains(query)),
        )
        .toList();
  }

  @override
  Future<List<PeriodoAcademico>> listarActivos() async =>
      items.where((item) => item.estado).toList();

  @override
  Future<PeriodoAcademico> crear({
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    created = true;
    final item = PeriodoAcademico(
      id: 3,
      nombre: nombre,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      estado: true,
    );
    items = [...items, item];
    return item;
  }

  @override
  Future<PeriodoAcademico> actualizar({
    required int id,
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    updated = true;
    return _activo;
  }

  @override
  Future<PeriodoAcademico> cambiarEstado({
    required int id,
    required bool estado,
  }) async {
    lastState = estado;
    return estado ? _activo : _inactivo;
  }
}

class _ErrorRepository extends _FakeRepository {
  @override
  Future<List<PeriodoAcademico>> listar({String? busqueda, bool? estado}) {
    throw Exception('Failed to fetch');
  }
}

class _DuplicateRepository extends _FakeRepository {
  @override
  Future<PeriodoAcademico> crear({
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) {
    throw const AppException(
      'Ya existe un periodo académico con este nombre.',
    );
  }
}
