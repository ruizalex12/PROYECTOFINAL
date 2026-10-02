import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/entities/estudiante_inscrito.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/repositories/estudiante_repository.dart';
import 'package:proyecto_final_360/features/estudiantes/presentation/controllers/estudiantes_asignacion_controller.dart';

void main() {
  test('consulta estudiantes usando la asignacion seleccionada', () async {
    final repository = _FakeRepository();
    final controller = EstudiantesAsignacionController(repository, 12);

    await controller.cargar();

    expect(repository.requestedId, 12);
    expect(controller.state, EstudiantesAsignacionState.data);
    expect(controller.items.single.nombreCompleto, 'Ana Flores');
  });

  test('representa una asignacion sin estudiantes activos', () async {
    final controller = EstudiantesAsignacionController(
      _FakeRepository(items: const []),
      12,
    );

    await controller.cargar();

    expect(controller.state, EstudiantesAsignacionState.empty);
  });
}

class _FakeRepository implements EstudianteRepository {
  _FakeRepository({
    this.items = const [
      EstudianteInscrito(
        inscripcionId: 20,
        estudianteId: 8,
        codigo: 'EST-008',
        nombres: 'Ana',
        apellidos: 'Flores',
        ci: '123456',
        estado: true,
      ),
    ],
  });

  final List<EstudianteInscrito> items;
  int? requestedId;

  @override
  Future<List<EstudianteInscrito>> listarPorAsignacion(
    int asignacionId,
  ) async {
    requestedId = asignacionId;
    return items;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
