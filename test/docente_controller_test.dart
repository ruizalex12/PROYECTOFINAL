import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/docentes/domain/entities/docente.dart';
import 'package:proyecto_final_360/features/docentes/domain/repositories/docente_repository.dart';
import 'package:proyecto_final_360/features/docentes/presentation/controllers/docente_controller.dart';
import 'package:proyecto_final_360/features/docentes/presentation/widgets/docente_form_validator.dart';

void main() {
  test('estado inicial loading', () {
    expect(
        DocenteController(_FakeRepository()).state, DocenteViewState.loading);
  });

  test('lista docentes', () async {
    final controller = DocenteController(_FakeRepository());
    await controller.cargar();
    expect(controller.state, DocenteViewState.data);
    expect(controller.items.length, 2);
  });

  test('representa lista vacía', () async {
    final controller = DocenteController(_FakeRepository(items: []));
    await controller.cargar();
    expect(controller.state, DocenteViewState.empty);
  });

  test('busca por nombres apellidos CI y correo', () async {
    for (final query in ['Ana', 'Flores', '111', 'ana@sfm.test']) {
      final controller = DocenteController(_FakeRepository());
      await controller.cargar(busqueda: query);
      expect(controller.items, [_activo]);
    }
  });

  test('filtra activos e inactivos', () async {
    final controller = DocenteController(_FakeRepository());
    await controller.cargar(estado: true);
    expect(controller.items, [_activo]);
    await controller.cargar(estado: false);
    expect(controller.items, [_inactivo]);
  });

  test('valida los campos editables obligatorios', () {
    expect(DocenteFormValidator.requiredNames(''), isNotNull);
    expect(DocenteFormValidator.requiredLastNames(' '), isNotNull);
    expect(DocenteFormValidator.requiredCi(null), isNotNull);
  });

  test('actualiza nombres apellidos CI y teléfono', () async {
    final repository = _FakeRepository();
    final error = await DocenteController(repository).actualizar(
      docente: _activo,
      nombres: 'Ana María',
      apellidos: 'Flores',
      ci: '111',
      telefono: '70000000',
      direccion: 'Calle 1',
      sexo: 'FEMENINO',
      fechaNacimiento: DateTime(1990, 1, 1),
      especialidad: 'Teología',
    );
    expect(error, isNull);
    expect(repository.updated, isTrue);
  });

  test('desactiva docente', () async {
    final repository = _FakeRepository();
    await DocenteController(repository).cambiarEstado(_activo);
    expect(repository.lastState, isFalse);
  });

  test('reactiva docente', () async {
    final repository = _FakeRepository();
    await DocenteController(repository).cambiarEstado(_inactivo);
    expect(repository.lastState, isTrue);
  });

  test('maneja error de carga', () async {
    final controller = DocenteController(_ErrorRepository());
    await controller.cargar();
    expect(controller.state, DocenteViewState.error);
    expect(
        controller.errorMessage, 'No fue posible conectarse con el servidor.');
  });
}

final _activo = Docente(
    id: 'docente-1',
    correo: 'ana@sfm.test',
    nombres: 'Ana',
    apellidos: 'Flores',
    ci: '111',
    telefono: '70000001',
    estado: true,
    fechaRegistro: DateTime(2026));
final _inactivo = Docente(
    id: 'docente-2',
    correo: 'luis@sfm.test',
    nombres: 'Luis',
    apellidos: 'Rojas',
    ci: '222',
    estado: false,
    fechaRegistro: DateTime(2026));

class _FakeRepository implements DocenteRepository {
  _FakeRepository({List<Docente>? items})
      : items = items ?? [_activo, _inactivo];
  List<Docente> items;
  bool updated = false;
  bool? lastState;

  @override
  Future<List<Docente>> listar({String? busqueda, bool? estado}) async {
    final query = busqueda?.trim().toLowerCase() ?? '';
    return items.where((item) {
      final text = [item.nombres, item.apellidos, item.ci, item.correo]
          .join(' ')
          .toLowerCase();
      return (estado == null || item.estado == estado) &&
          (query.isEmpty || text.contains(query));
    }).toList();
  }

  @override
  Future<Docente> actualizar(
      {required String id,
      required String nombres,
      required String apellidos,
      required String ci,
      String? telefono,
      String? direccion,
      required String sexo,
      required DateTime fechaNacimiento,
      required String especialidad,
      String? tituloProfesional,
      String? gradoAcademico,
      DateTime? fechaIncorporacion,
      String? observaciones}) async {
    updated = true;
    return _activo;
  }

  @override
  Future<Docente> cambiarEstado(
      {required String id, required bool estado}) async {
    lastState = estado;
    return estado ? _activo : _inactivo;
  }
}

class _ErrorRepository extends _FakeRepository {
  @override
  Future<List<Docente>> listar({String? busqueda, bool? estado}) =>
      throw Exception('Failed to fetch');
}
