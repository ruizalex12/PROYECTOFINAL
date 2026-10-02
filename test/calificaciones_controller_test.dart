import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/calificaciones/domain/entities/calificacion.dart';
import 'package:proyecto_final_360/features/calificaciones/domain/repositories/calificacion_repository.dart';
import 'package:proyecto_final_360/features/calificaciones/presentation/controllers/calificaciones_controller.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/entities/estudiante_inscrito.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/repositories/estudiante_repository.dart';

void main() {
  test('acepta notas en los limites 0 y 100', () {
    expect(CalificacionRules.notaValida(0), isTrue);
    expect(CalificacionRules.notaValida(100), isTrue);
  });

  test('rechaza notas menores a 0 y mayores a 100', () {
    expect(CalificacionRules.notaValida(-0.01), isFalse);
    expect(CalificacionRules.notaValida(100.01), isFalse);
  });

  test('crea una calificacion para la asignacion propia', () async {
    final repository = _FakeCalificacionRepository();
    final controller = CalificacionesController(
      repository,
      _FakeEstudianteRepository(),
      5,
    );
    await controller.cargar();

    final error = await controller.guardar(
      inscripcionId: 20,
      tipoEvaluacion: 'Parcial 1',
      nota: '85.5',
    );

    expect(error, isNull);
    expect(repository.lastNota, 85.5);
    expect(repository.lastAsignacionId, 5);
  });

  test('actualiza una calificacion existente', () async {
    final repository = _FakeCalificacionRepository();
    final controller = CalificacionesController(
      repository,
      _FakeEstudianteRepository(),
      5,
    );
    final existing = _calificacion(nota: 70);

    final error = await controller.guardar(
      existente: existing,
      inscripcionId: 20,
      tipoEvaluacion: 'Parcial 1',
      nota: '90',
    );

    expect(error, isNull);
    expect(repository.lastId, existing.id);
    expect(repository.lastNota, 90);
  });
}

Calificacion _calificacion({required double nota}) => Calificacion(
      id: 30,
      inscripcionId: 20,
      asignacionDocenteId: 5,
      tipoEvaluacion: 'Parcial 1',
      nota: nota,
      fechaRegistro: DateTime.utc(2026, 9, 30),
    );

class _FakeCalificacionRepository implements CalificacionRepository {
  int? lastId;
  int? lastAsignacionId;
  double? lastNota;

  @override
  Future<Calificacion> guardar({
    int? id,
    required int inscripcionId,
    required int asignacionId,
    required String tipoEvaluacion,
    required double nota,
    String? observacion,
  }) async {
    lastId = id;
    lastAsignacionId = asignacionId;
    lastNota = nota;
    return Calificacion(
      id: id ?? 31,
      inscripcionId: inscripcionId,
      asignacionDocenteId: asignacionId,
      tipoEvaluacion: tipoEvaluacion,
      nota: nota,
      observacion: observacion,
      fechaRegistro: DateTime.utc(2026, 9, 30),
    );
  }

  @override
  Future<List<Calificacion>> listarPorAsignacion(int asignacionId) async =>
      const [];
}

class _FakeEstudianteRepository implements EstudianteRepository {
  @override
  Future<List<EstudianteInscrito>> listarPorAsignacion(
    int asignacionId,
  ) async =>
      const [
        EstudianteInscrito(
          inscripcionId: 20,
          estudianteId: 8,
          nombres: 'Ana',
          apellidos: 'Flores',
          ci: '123456',
          estado: true,
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
