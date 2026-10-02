import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/asignaciones_docente/domain/entities/asignacion_docente.dart';
import 'package:proyecto_final_360/features/asignaciones_docente/domain/repositories/asignacion_docente_repository.dart';
import 'package:proyecto_final_360/features/asignaciones_docente/presentation/controllers/mis_asignaturas_controller.dart';
import 'package:proyecto_final_360/features/asignaturas/domain/entities/asignatura.dart';

void main() {
  test('representa lista vacia de asignaciones propias', () async {
    final controller = MisAsignaturasController(_FakeRepository());

    await controller.cargar();

    expect(controller.state, MisAsignaturasState.empty);
  });

  test('lista solamente las asignaciones entregadas por el repositorio',
      () async {
    final controller = MisAsignaturasController(
      _FakeRepository(items: [_asignacion]),
    );

    await controller.cargar();

    expect(controller.state, MisAsignaturasState.data);
    expect(controller.items.single.id, 7);
    expect(controller.items.single.asignatura.codigo, 'SFM-101');
  });

  test('muestra un error comprensible cuando falla la consulta', () async {
    final controller = MisAsignaturasController(_ErrorRepository());

    await controller.cargar();

    expect(controller.state, MisAsignaturasState.error);
    expect(
      controller.errorMessage,
      'No fue posible conectarse con el servidor.',
    );
  });
}

final _asignacion = AsignacionDocente(
  id: 7,
  docenteId: 'docente-1',
  docenteNombre: 'Docente Prueba',
  docenteCorreo: 'docente@prueba.test',
  asignatura: Asignatura(
    id: 2,
    codigo: 'SFM-101',
    nombre: 'Hermeneutica',
    estado: true,
    fechaRegistro: DateTime.utc(2026, 1, 1),
  ),
  periodo: PeriodoAsignacion(
    id: 3,
    nombre: 'Gestion 2026',
    fechaInicio: DateTime.utc(2026, 2, 1),
    fechaFin: DateTime.utc(2026, 11, 30),
    estado: true,
  ),
  fechaAsignacion: DateTime.utc(2026, 2, 1),
  estado: true,
);

class _FakeRepository implements AsignacionDocenteRepository {
  _FakeRepository({this.items = const []});

  final List<AsignacionDocente> items;

  @override
  Future<List<AsignacionDocente>> listarPropiasActivas() async => items;

  @override
  Future<List<AsignacionDocente>> listar() async => items;

  @override
  Future<AsignacionDocenteOptions> cargarOpciones() async =>
      const AsignacionDocenteOptions(
        docentes: [],
        asignaturas: [],
        periodos: [],
      );

  @override
  Future<AsignacionDocente> crear({
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  }) async =>
      _asignacion;

  @override
  Future<AsignacionDocente> actualizar({
    required int id,
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  }) async =>
      _asignacion;

  @override
  Future<AsignacionDocente> cambiarEstado({
    required int id,
    required bool estado,
  }) async =>
      _asignacion;
}

class _ErrorRepository extends _FakeRepository {
  @override
  Future<List<AsignacionDocente>> listarPropiasActivas() {
    throw Exception('Failed to fetch');
  }
}
