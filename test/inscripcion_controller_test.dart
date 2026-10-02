import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/core/errors/app_exception.dart';
import 'package:proyecto_final_360/features/inscripciones/domain/entities/inscripcion.dart';
import 'package:proyecto_final_360/features/inscripciones/domain/repositories/inscripcion_repository.dart';
import 'package:proyecto_final_360/features/inscripciones/presentation/controllers/inscripcion_controller.dart';

void main() {
  test('estado inicial loading', () {
    expect(
      InscripcionController(_FakeRepository()).state,
      InscripcionViewState.loading,
    );
  });

  test('representa lista vacía', () async {
    final controller = InscripcionController(_FakeRepository(items: []));
    await controller.cargar();
    expect(controller.state, InscripcionViewState.empty);
  });

  test('representa error', () async {
    final controller = InscripcionController(_ErrorRepository());
    await controller.cargar();
    expect(controller.state, InscripcionViewState.error);
    expect(
        controller.errorMessage, 'No fue posible conectarse con el servidor.');
  });

  test('lista inscripciones', () async {
    final controller = InscripcionController(_FakeRepository());
    await controller.cargar();
    expect(controller.state, InscripcionViewState.data);
    expect(controller.items.first.estudianteNombre, 'Ana Flores');
  });

  test('crea inscripción', () async {
    final repository = _FakeRepository(items: []);
    final controller = InscripcionController(repository);
    final error = await controller.guardar(
      estudianteId: 1,
      asignaturaId: 10,
      periodoId: 100,
    );
    expect(error, isNull);
    expect(repository.created, isTrue);
  });

  test('muestra mensaje de duplicado', () async {
    final controller = InscripcionController(
      _RuleErrorRepository(_duplicateMessage),
    );
    final error = await controller.guardar(
      estudianteId: 1,
      asignaturaId: 10,
      periodoId: 100,
    );
    expect(error, _duplicateMessage);
  });

  test('actualiza inscripción', () async {
    final repository = _FakeRepository();
    final controller = InscripcionController(repository);
    final error = await controller.guardar(
      existente: _activa,
      estudianteId: 1,
      asignaturaId: 20,
      periodoId: 100,
    );
    expect(error, isNull);
    expect(repository.updated, isTrue);
  });

  test('desactiva inscripción', () async {
    final repository = _FakeRepository();
    await InscripcionController(repository).cambiarEstado(_activa);
    expect(repository.lastState, isFalse);
  });

  test('reactiva inscripción', () async {
    final repository = _FakeRepository();
    await InscripcionController(repository).cambiarEstado(_inactiva);
    expect(repository.lastState, isTrue);
  });

  test('filtra por estudiante', () async {
    final controller = InscripcionController(_FakeRepository());
    await controller.cargar();
    expect(controller.filtrar(estudianteId: 1), [_activa]);
  });

  test('filtra por asignatura', () async {
    final controller = InscripcionController(_FakeRepository());
    await controller.cargar();
    expect(controller.filtrar(asignaturaId: 20), [_inactiva]);
  });

  test('filtra por periodo y estado', () async {
    final controller = InscripcionController(_FakeRepository());
    await controller.cargar();
    expect(controller.filtrar(periodoId: 100, estado: true), [_activa]);
    expect(controller.filtrar(estado: false), [_inactiva]);
  });

  test('busca por datos relacionados', () async {
    final controller = InscripcionController(_FakeRepository());
    await controller.cargar();
    expect(controller.filtrar(busqueda: 'sfm-101'), [_activa]);
    expect(controller.filtrar(busqueda: 'gestión 2025'), [_inactiva]);
  });

  test('selectores contienen solamente opciones activas', () async {
    final controller = InscripcionController(_FakeRepository());
    await controller.cargar();
    expect(controller.options.estudiantes.map((item) => item.id), [1]);
    expect(controller.options.asignaturas.map((item) => item.id), [10]);
    expect(controller.options.periodos.map((item) => item.id), [100]);
  });

  for (final rule in {
    'estudiante inactivo': 'El estudiante seleccionado no se encuentra activo.',
    'asignatura inactiva': 'La asignatura seleccionada no se encuentra activa.',
    'periodo inactivo':
        'El periodo académico seleccionado no se encuentra activo.',
  }.entries) {
    test('rechaza ${rule.key}', () async {
      final controller =
          InscripcionController(_RuleErrorRepository(rule.value));
      final error = await controller.guardar(
        estudianteId: 1,
        asignaturaId: 10,
        periodoId: 100,
      );
      expect(error, rule.value);
    });
  }
}

const _duplicateMessage =
    'El estudiante ya se encuentra inscrito en esta asignatura para el periodo seleccionado.';

final _activa = Inscripcion(
  id: 1,
  estudianteId: 1,
  estudianteNombre: 'Ana Flores',
  estudianteActivo: true,
  asignaturaId: 10,
  asignaturaCodigo: 'SFM-101',
  asignaturaNombre: 'Introducción',
  asignaturaActiva: true,
  periodoId: 100,
  periodoNombre: 'Gestión 2026',
  periodoActivo: true,
  fechaInscripcion: DateTime(2026, 1, 10),
  estado: true,
);

final _inactiva = Inscripcion(
  id: 2,
  estudianteId: 2,
  estudianteNombre: 'Luis Rojas',
  estudianteActivo: false,
  asignaturaId: 20,
  asignaturaCodigo: 'SFM-102',
  asignaturaNombre: 'Historia',
  asignaturaActiva: false,
  periodoId: 200,
  periodoNombre: 'Gestión 2025',
  periodoActivo: false,
  fechaInscripcion: DateTime(2025, 1, 10),
  estado: false,
);

class _FakeRepository implements InscripcionRepository {
  _FakeRepository({List<Inscripcion>? items})
      : items = items ?? [_activa, _inactiva];

  List<Inscripcion> items;
  bool created = false;
  bool updated = false;
  bool? lastState;

  @override
  Future<List<Inscripcion>> listar() async => items;

  @override
  Future<InscripcionOptions> cargarOpciones() async => const InscripcionOptions(
        estudiantes: [InscripcionOption(id: 1, label: 'Ana Flores')],
        asignaturas: [
          InscripcionOption(id: 10, label: 'SFM-101 · Introducción')
        ],
        periodos: [InscripcionOption(id: 100, label: 'Gestión 2026')],
      );

  @override
  Future<Inscripcion> crear({
    required int estudianteId,
    required int asignaturaId,
    required int periodoId,
  }) async {
    created = true;
    items = [...items, _activa];
    return _activa;
  }

  @override
  Future<Inscripcion> actualizar({
    required int id,
    required int estudianteId,
    required int asignaturaId,
    required int periodoId,
  }) async {
    updated = true;
    return _activa;
  }

  @override
  Future<Inscripcion> cambiarEstado(
      {required int id, required bool estado}) async {
    lastState = estado;
    return estado ? _activa : _inactiva;
  }
}

class _ErrorRepository extends _FakeRepository {
  @override
  Future<List<Inscripcion>> listar() => throw Exception('Failed to fetch');
}

class _RuleErrorRepository extends _FakeRepository {
  _RuleErrorRepository(this.message);
  final String message;

  @override
  Future<Inscripcion> crear({
    required int estudianteId,
    required int asignaturaId,
    required int periodoId,
  }) =>
      throw AppException(message);
}
