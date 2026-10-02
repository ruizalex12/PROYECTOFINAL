import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/core/errors/app_exception.dart';
import 'package:proyecto_final_360/features/asignaciones_docente/domain/entities/asignacion_docente.dart';
import 'package:proyecto_final_360/features/asignaciones_docente/domain/repositories/asignacion_docente_repository.dart';
import 'package:proyecto_final_360/features/asignaciones_docente/presentation/controllers/asignacion_docente_controller.dart';
import 'package:proyecto_final_360/features/asignaturas/domain/entities/asignatura.dart';

void main() {
  test('estado inicial loading', () {
    final controller = AsignacionDocenteController(_FakeRepository());
    expect(controller.state, AsignacionDocenteViewState.loading);
  });

  test('representa lista vacia', () async {
    final controller = AsignacionDocenteController(
      _FakeRepository(items: const []),
    );
    await controller.cargar();
    expect(controller.state, AsignacionDocenteViewState.empty);
  });

  test('representa error de carga con mensaje comprensible', () async {
    final controller = AsignacionDocenteController(_ErrorRepository());
    await controller.cargar();
    expect(controller.state, AsignacionDocenteViewState.error);
    expect(
      controller.errorMessage,
      'No fue posible conectarse con el servidor.',
    );
  });

  test('lista asignaciones con datos relacionados', () async {
    final controller = AsignacionDocenteController(_FakeRepository());
    await controller.cargar();
    expect(controller.state, AsignacionDocenteViewState.data);
    expect(controller.items.single.docenteNombre, 'María Docente');
    expect(controller.items.single.asignatura.codigo, 'SFM-101');
  });

  test('registra una asignacion correcta', () async {
    final repository = _FakeRepository(items: const []);
    final controller = AsignacionDocenteController(repository);
    final error = await controller.guardar(
      docenteId: 'docente-1',
      asignaturaId: 2,
      periodoId: 3,
    );
    expect(error, isNull);
    expect(repository.created, isTrue);
  });

  test('muestra el mensaje especifico para asignacion duplicada', () async {
    final controller = AsignacionDocenteController(_DuplicateRepository());
    final error = await controller.guardar(
      docenteId: 'docente-1',
      asignaturaId: 2,
      periodoId: 3,
    );
    expect(
      error,
      'El docente ya se encuentra asignado a esta asignatura en el periodo seleccionado.',
    );
  });

  test('actualiza docente asignatura y periodo', () async {
    final repository = _FakeRepository();
    final controller = AsignacionDocenteController(repository);
    final error = await controller.guardar(
      existente: _asignacion,
      docenteId: 'docente-2',
      asignaturaId: 4,
      periodoId: 5,
    );
    expect(error, isNull);
    expect(repository.updated, isTrue);
  });

  test('aplica baja logica y reactivacion', () async {
    final repository = _FakeRepository();
    final controller = AsignacionDocenteController(repository);
    await controller.cambiarEstado(_asignacion);
    expect(repository.lastState, isFalse);
    await controller.cambiarEstado(_inactiva);
    expect(repository.lastState, isTrue);
  });

  test('los selectores contienen solo opciones activas entregadas', () async {
    final controller = AsignacionDocenteController(_FakeRepository());
    await controller.cargar();
    expect(controller.options.docentes.single.nombre, 'María Docente');
    expect(controller.options.asignaturas.single.codigo, 'SFM-101');
    expect(controller.options.periodos.single.nombre, 'Gestión 2026');
  });
}

final _asignacion = AsignacionDocente(
  id: 7,
  docenteId: 'docente-1',
  docenteNombre: 'María Docente',
  docenteCorreo: 'docente@sfm.test',
  asignatura: Asignatura(
    id: 2,
    codigo: 'SFM-101',
    nombre: 'Hermeneútica',
    estado: true,
    fechaRegistro: DateTime.utc(2026, 1, 1),
  ),
  periodo: PeriodoAsignacion(
    id: 3,
    nombre: 'Gestión 2026',
    fechaInicio: DateTime.utc(2026, 2, 1),
    fechaFin: DateTime.utc(2026, 11, 30),
    estado: true,
  ),
  fechaAsignacion: DateTime.utc(2026, 2, 1),
  estado: true,
);

final _inactiva = AsignacionDocente(
  id: _asignacion.id,
  docenteId: _asignacion.docenteId,
  docenteNombre: _asignacion.docenteNombre,
  docenteCorreo: _asignacion.docenteCorreo,
  asignatura: _asignacion.asignatura,
  periodo: _asignacion.periodo,
  fechaAsignacion: _asignacion.fechaAsignacion,
  estado: false,
);

class _FakeRepository implements AsignacionDocenteRepository {
  _FakeRepository({List<AsignacionDocente>? items})
      : items = items ?? [_asignacion];

  List<AsignacionDocente> items;
  bool created = false;
  bool updated = false;
  bool? lastState;

  @override
  Future<List<AsignacionDocente>> listar() async => items;

  @override
  Future<List<AsignacionDocente>> listarPropiasActivas() async =>
      items.where((item) => item.estado).toList();

  @override
  Future<AsignacionDocenteOptions> cargarOpciones() async =>
      const AsignacionDocenteOptions(
        docentes: [
          DocenteOption(
            id: 'docente-1',
            nombre: 'María Docente',
            correo: 'docente@sfm.test',
          ),
        ],
        asignaturas: [
          AsignaturaOption(id: 2, codigo: 'SFM-101', nombre: 'Hermeneútica'),
        ],
        periodos: [PeriodoOption(id: 3, nombre: 'Gestión 2026')],
      );

  @override
  Future<AsignacionDocente> crear({
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  }) async {
    created = true;
    items = [_asignacion];
    return _asignacion;
  }

  @override
  Future<AsignacionDocente> actualizar({
    required int id,
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  }) async {
    updated = true;
    return _asignacion;
  }

  @override
  Future<AsignacionDocente> cambiarEstado({
    required int id,
    required bool estado,
  }) async {
    lastState = estado;
    return estado ? _asignacion : _inactiva;
  }
}

class _ErrorRepository extends _FakeRepository {
  @override
  Future<List<AsignacionDocente>> listar() {
    throw Exception('Failed to fetch');
  }
}

class _DuplicateRepository extends _FakeRepository {
  @override
  Future<AsignacionDocente> crear({
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  }) {
    throw const AppException(
      'El docente ya se encuentra asignado a esta asignatura en el periodo seleccionado.',
    );
  }
}
