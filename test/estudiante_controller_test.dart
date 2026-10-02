import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/core/errors/app_exception.dart';
import 'package:proyecto_final_360/features/estudiantes/data/models/estudiante_model.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/entities/estudiante.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/entities/estudiante_inscrito.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/repositories/estudiante_repository.dart';
import 'package:proyecto_final_360/features/estudiantes/presentation/controllers/estudiante_controller.dart';

void main() {
  test('payload INSERT omite codigo y conserva datos de creación', () {
    final payload = EstudianteModel.createPayload(
      nombres: 'Marta',
      apellidos: 'Ríos',
      ci: '333',
      telefono: '70000003',
    );

    expect(payload, isNot(contains('codigo')));
    expect(payload['nombres'], 'Marta');
    expect(payload['estado'], isTrue);
  });

  test('payload UPDATE omite codigo', () {
    final payload = EstudianteModel.updatePayload(
      nombres: 'Ana María',
      apellidos: 'Flores',
      ci: '111',
    );

    expect(payload, isNot(contains('codigo')));
    expect(payload, isNot(contains('estado')));
  });

  test('estado inicial loading', () {
    final controller = EstudianteController(_FakeRepository());
    expect(controller.state, EstudianteViewState.loading);
  });

  test('representa lista vacia', () async {
    final controller = EstudianteController(_FakeRepository(items: []));
    await controller.cargar();
    expect(controller.state, EstudianteViewState.empty);
  });

  test('representa estado error', () async {
    final controller = EstudianteController(_ErrorRepository());
    await controller.cargar();
    expect(controller.state, EstudianteViewState.error);
    expect(
      controller.errorMessage,
      'No fue posible conectarse con el servidor.',
    );
  });

  test('lista estudiantes con datos', () async {
    final controller = EstudianteController(_FakeRepository());
    await controller.cargar();
    expect(controller.state, EstudianteViewState.data);
    expect(controller.items.first.nombreCompleto, 'Ana Flores');
  });

  test('crea estudiante correctamente', () async {
    final repository = _FakeRepository(items: []);
    final controller = EstudianteController(repository);
    final error = await controller.guardar(
      nombres: '  Marta ',
      apellidos: ' Ríos ',
      ci: ' 333 ',
    );
    expect(error, isNull);
    expect(repository.created, isTrue);
    expect(controller.ultimoGuardado?.codigo, 'EST0003');
  });

  test('rechaza CI duplicado', () async {
    final controller = EstudianteController(_DuplicateRepository(ci: true));
    final error = await controller.guardar(
      nombres: 'Marta',
      apellidos: 'Ríos',
      ci: '111',
    );
    expect(error, 'Ya existe un estudiante registrado con este CI.');
  });

  test('rechaza codigo duplicado', () async {
    final controller = EstudianteController(_DuplicateRepository(ci: false));
    final error = await controller.guardar(
      nombres: 'Marta',
      apellidos: 'Ríos',
      ci: '333',
    );
    expect(error, 'Ya existe un estudiante registrado con este código.');
  });

  test('actualiza estudiante', () async {
    final repository = _FakeRepository();
    final controller = EstudianteController(repository);
    final error = await controller.guardar(
      existente: _ana,
      nombres: 'Ana María',
      apellidos: 'Flores',
      ci: '111',
    );
    expect(error, isNull);
    expect(repository.updated, isTrue);
  });

  test('desactiva estudiante mediante baja logica', () async {
    final repository = _FakeRepository();
    final controller = EstudianteController(repository);
    await controller.cambiarEstado(_ana);
    expect(repository.lastState, isFalse);
  });

  test('reactiva estudiante', () async {
    final repository = _FakeRepository();
    final controller = EstudianteController(repository);
    await controller.cambiarEstado(_inactivo);
    expect(repository.lastState, isTrue);
  });

  test('filtra estudiantes activos', () async {
    final controller = EstudianteController(_FakeRepository());
    await controller.cargar(estado: true);
    expect(controller.items.every((item) => item.estado), isTrue);
  });

  test('filtra estudiantes inactivos', () async {
    final controller = EstudianteController(_FakeRepository());
    await controller.cargar(estado: false);
    expect(controller.items.single.estado, isFalse);
  });

  test('busca estudiante por nombre', () async {
    final controller = EstudianteController(_FakeRepository());
    await controller.cargar(busqueda: 'ana');
    expect(controller.items.single.nombreCompleto, 'Ana Flores');
  });

  test('busca estudiante por CI', () async {
    final controller = EstudianteController(_FakeRepository());
    await controller.cargar(busqueda: '222');
    expect(controller.items.single.ci, '222');
  });

  test('busca estudiante por código', () async {
    final controller = EstudianteController(_FakeRepository());
    await controller.cargar(busqueda: 'EST-001');
    expect(controller.items.single.codigo, 'EST-001');
  });
}

final _ana = Estudiante(
  id: 1,
  codigo: 'EST-001',
  nombres: 'Ana',
  apellidos: 'Flores',
  ci: '111',
  telefono: '70000001',
  estado: true,
  fechaRegistro: DateTime.utc(2026, 1, 1),
);

final _inactivo = Estudiante(
  id: 2,
  codigo: 'EST-002',
  nombres: 'Luis',
  apellidos: 'Rojas',
  ci: '222',
  estado: false,
  fechaRegistro: DateTime.utc(2026, 1, 2),
);

class _FakeRepository implements EstudianteRepository {
  _FakeRepository({List<Estudiante>? items})
      : items = items ?? [_ana, _inactivo];

  List<Estudiante> items;
  bool created = false;
  bool updated = false;
  bool? lastState;

  @override
  Future<List<Estudiante>> listar({String? busqueda, bool? estado}) async {
    final query = busqueda?.trim().toLowerCase() ?? '';
    return items.where((item) {
      final matchesState = estado == null || item.estado == estado;
      final text = [
        item.codigo,
        item.nombres,
        item.apellidos,
        item.ci,
      ].join(' ').toLowerCase();
      return matchesState && (query.isEmpty || text.contains(query));
    }).toList();
  }

  @override
  Future<Estudiante> crear({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) async {
    created = true;
    final item = Estudiante(
      id: 3,
      codigo: 'EST0003',
      nombres: nombres.trim(),
      apellidos: apellidos.trim(),
      ci: ci.trim(),
      telefono: telefono?.trim(),
      estado: true,
      fechaRegistro: DateTime.utc(2026, 1, 3),
    );
    items = [...items, item];
    return item;
  }

  @override
  Future<Estudiante> actualizar({
    required int id,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) async {
    updated = true;
    return _ana;
  }

  @override
  Future<Estudiante> cambiarEstado({
    required int id,
    required bool estado,
  }) async {
    lastState = estado;
    return estado ? _ana : _inactivo;
  }

  @override
  Future<int> contarActivos() async =>
      items.where((item) => item.estado).length;

  @override
  Future<List<EstudianteInscrito>> listarPorAsignacion(
    int asignacionId,
  ) async =>
      const [];
}

class _ErrorRepository extends _FakeRepository {
  @override
  Future<List<Estudiante>> listar({String? busqueda, bool? estado}) {
    throw Exception('Failed to fetch');
  }
}

class _DuplicateRepository extends _FakeRepository {
  _DuplicateRepository({required this.ci});

  final bool ci;

  @override
  Future<Estudiante> crear({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) {
    throw AppException(
      this.ci
          ? 'Ya existe un estudiante registrado con este CI.'
          : 'Ya existe un estudiante registrado con este código.',
    );
  }
}
