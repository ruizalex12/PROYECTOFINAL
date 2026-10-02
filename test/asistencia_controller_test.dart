import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/asistencia/domain/entities/asistencia.dart';
import 'package:proyecto_final_360/features/asistencia/domain/repositories/asistencia_repository.dart';
import 'package:proyecto_final_360/features/asistencia/presentation/controllers/asistencia_controller.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/entities/estudiante_inscrito.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/repositories/estudiante_repository.dart';

void main() {
  test('carga estudiantes con PRESENTE como estado inicial', () async {
    final controller = AsistenciaController(
      _FakeAsistenciaRepository(),
      _FakeEstudianteRepository(),
      5,
      fechaInicial: DateTime(2026, 9, 30),
    );

    await controller.cargar();

    expect(controller.state, AsistenciaViewState.data);
    expect(controller.items.single.estado, EstadoAsistencia.presente);
  });

  test('recupera y actualiza una asistencia existente', () async {
    final repository = _FakeAsistenciaRepository(
      items: [
        Asistencia(
          id: 10,
          inscripcionId: 20,
          asignacionDocenteId: 5,
          fecha: DateTime(2026, 9, 30),
          estado: EstadoAsistencia.ausente,
        ),
      ],
    );
    final controller = AsistenciaController(
      repository,
      _FakeEstudianteRepository(),
      5,
      fechaInicial: DateTime(2026, 9, 30),
    );
    await controller.cargar();
    expect(controller.items.single.estado, EstadoAsistencia.ausente);

    controller.cambiarEstado(0, EstadoAsistencia.licencia);
    final error = await controller.guardar();

    expect(error, isNull);
    expect(repository.saved.single.estado, EstadoAsistencia.licencia);
    expect(repository.saved.single.asignacionDocenteId, 5);
  });

  test('solo admite los tres estados academicos definidos', () {
    expect(
      EstadoAsistencia.values.map((item) => item.databaseValue),
      ['PRESENTE', 'AUSENTE', 'LICENCIA'],
    );
  });
}

class _FakeAsistenciaRepository implements AsistenciaRepository {
  _FakeAsistenciaRepository({this.items = const []});

  final List<Asistencia> items;
  List<Asistencia> saved = const [];

  @override
  Future<List<Asistencia>> guardarTodos(List<Asistencia> registros) async {
    saved = registros;
    return registros;
  }

  @override
  Future<List<Asistencia>> listarPorFecha({
    required int asignacionId,
    required DateTime fecha,
  }) async =>
      items;
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
