import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/asignaturas/domain/entities/asignatura.dart';
import 'package:proyecto_final_360/features/asignaturas/domain/repositories/asignatura_repository.dart';
import 'package:proyecto_final_360/features/asignaturas/presentation/controllers/asignatura_controller.dart';

void main() {
  test('inicia en estado loading', () {
    final controller = AsignaturaController(_FakeRepository());
    expect(controller.state, AsignaturaViewState.loading);
  });

  test('representa el estado vacio', () async {
    final controller = AsignaturaController(_FakeRepository());
    await controller.cargar();
    expect(controller.state, AsignaturaViewState.empty);
  });

  test('representa el estado error con un mensaje amigable', () async {
    final controller = AsignaturaController(_ErrorRepository());
    await controller.cargar();

    expect(controller.state, AsignaturaViewState.error);
    expect(
      controller.errorMessage,
      'No fue posible conectarse con el servidor.',
    );
  });

  test('crea y lista una asignatura', () async {
    final repository = _FakeRepository();
    final controller = AsignaturaController(repository);

    final error = await controller.guardar(
      codigo: 'sfm-101',
      nombre: 'Hermeneutica',
      descripcion: 'Prueba',
    );

    expect(error, isNull);
    expect(controller.state, AsignaturaViewState.data);
    expect(controller.items.single.codigo, 'SFM-101');
  });

  test('aplica baja logica y reactivacion', () async {
    final repository = _FakeRepository();
    final controller = AsignaturaController(repository);
    await controller.guardar(codigo: 'SFM-101', nombre: 'Hermeneutica');

    await controller.cambiarEstado(controller.items.single);
    expect(controller.items.single.estado, isFalse);

    await controller.cambiarEstado(controller.items.single);
    expect(controller.items.single.estado, isTrue);
  });
}

class _ErrorRepository extends _FakeRepository {
  @override
  Future<List<Asignatura>> listar() {
    throw Exception('Failed to fetch');
  }
}

class _FakeRepository implements AsignaturaRepository {
  final List<Asignatura> _items = [];

  @override
  Future<Asignatura> actualizar({
    required int id,
    required String codigo,
    required String nombre,
    String? descripcion,
  }) async {
    final index = _items.indexWhere((item) => item.id == id);
    _items[index] = _items[index].copyWith(
      codigo: codigo.trim().toUpperCase(),
      nombre: nombre.trim(),
      descripcion: descripcion?.trim(),
    );
    return _items[index];
  }

  @override
  Future<Asignatura> cambiarEstado(
      {required int id, required bool estado}) async {
    final index = _items.indexWhere((item) => item.id == id);
    _items[index] = _items[index].copyWith(estado: estado);
    return _items[index];
  }

  @override
  Future<Asignatura> crear({
    required String codigo,
    required String nombre,
    String? descripcion,
  }) async {
    final item = Asignatura(
      id: _items.length + 1,
      codigo: codigo.trim().toUpperCase(),
      nombre: nombre.trim(),
      descripcion: descripcion?.trim(),
      estado: true,
      fechaRegistro: DateTime.utc(2026, 9, 25),
    );
    _items.add(item);
    return item;
  }

  @override
  Future<List<Asignatura>> listar() async => List.unmodifiable(_items);
}
