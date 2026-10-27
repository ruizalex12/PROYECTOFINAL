import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_360/core/theme/app_theme.dart';
import 'package:proyecto_final_360/features/asignaciones_docente/domain/entities/asignacion_docente.dart';
import 'package:proyecto_final_360/features/asignaciones_docente/domain/repositories/asignacion_docente_repository.dart';
import 'package:proyecto_final_360/features/asignaturas/domain/entities/asignatura.dart';
import 'package:proyecto_final_360/features/asistencia/domain/entities/asistencia.dart';
import 'package:proyecto_final_360/features/asistencias_admin/domain/entities/consulta_asistencia.dart';
import 'package:proyecto_final_360/features/asistencias_admin/domain/repositories/consulta_asistencia_repository.dart';
import 'package:proyecto_final_360/features/calificaciones/domain/entities/calificacion.dart';
import 'package:proyecto_final_360/features/calificaciones/domain/repositories/calificacion_repository.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/entities/estudiante_inscrito.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/repositories/estudiante_repository.dart';
import 'package:proyecto_final_360/features/resumen_academico/domain/entities/resumen_academico.dart';
import 'package:proyecto_final_360/features/resumen_academico/presentation/controllers/resumen_academico_controller.dart';
import 'package:proyecto_final_360/features/resumen_academico/presentation/pages/resumen_academico_page.dart';

void main() {
  group('ResumenAcademico', () {
    test('muestra únicamente estudiantes inscritos en la asignación', () {
      final resumen = _crearResumen();

      expect(
        resumen.estudiantes.map((item) => item.estudiante.nombreCompleto),
        ['Ana Flores', 'Luis Rojas'],
      );
      expect(
        resumen.estudiantes
            .firstWhere((item) => item.estudiante.estudianteId == 8)
            .calificaciones
            .length,
        2,
      );
      expect(
        resumen.estudiantes
            .firstWhere((item) => item.estudiante.estudianteId == 8)
            .asistencias
            .length,
        4,
      );
    });

    test('calcula correctamente el promedio de calificaciones', () {
      final resumen = _crearResumen();
      final ana = resumen.estudiantes.first;

      expect(ana.promedioCalificaciones, 90);
      expect(resumen.promedioCalificaciones, 90);
    });

    test('calcula correctamente el porcentaje de asistencia', () {
      final resumen = _crearResumen();
      final ana = resumen.estudiantes.first;

      expect(ana.presentes, 2);
      expect(ana.ausentes, 1);
      expect(ana.licencias, 1);
      expect(ana.porcentajeAsistencia, 50);
      expect(resumen.porcentajeAsistencia, 50);
    });

    test('admite un estudiante sin calificación', () {
      final luis = _crearResumen().estudiantes.last;

      expect(luis.calificaciones, isEmpty);
      expect(luis.promedioCalificaciones, isNull);
    });

    test('admite un estudiante sin registros de asistencia', () {
      final luis = _crearResumen().estudiantes.last;

      expect(luis.asistencias, isEmpty);
      expect(luis.porcentajeAsistencia, isNull);
    });
  });

  group('ResumenAcademicoController', () {
    test('abre el resumen únicamente para una asignación propia', () async {
      final repositories = _Repositories();
      final controller = repositories.controller(7);

      await controller.cargar();

      expect(controller.state, ResumenAcademicoState.data);
      expect(controller.asignacion?.id, 7);
      expect(repositories.asignaciones.calls, 1);
      expect(repositories.estudiantes.requestedId, 7);
      expect(repositories.calificaciones.requestedId, 7);
      expect(repositories.asistencias.lastFilter?.asignaturaId, 2);
      expect(repositories.asistencias.lastFilter?.periodoId, 3);
      expect(repositories.asistencias.lastFilter?.docenteId, 'docente-1');
    });

    test('rechaza una asignación que no está entre las propias', () async {
      final repositories = _Repositories();
      final controller = repositories.controller(99);

      await controller.cargar();

      expect(controller.state, ResumenAcademicoState.error);
      expect(
        controller.errorMessage,
        'La asignación no existe o no está autorizada.',
      );
      expect(repositories.estudiantes.calls, 0);
      expect(repositories.asistencias.calls, 0);
      expect(repositories.calificaciones.calls, 0);
    });

    test('representa una asignación sin estudiantes con estado vacío',
        () async {
      final repositories = _Repositories(estudiantes: const []);
      final controller = repositories.controller(7);

      await controller.cargar();

      expect(controller.state, ResumenAcademicoState.empty);
      expect(controller.resumen?.totalInscritos, 0);
      expect(repositories.asistencias.calls, 0);
      expect(repositories.calificaciones.calls, 0);
    });
  });

  group('ResumenAcademicoPage', () {
    testWidgets('muestra datos, calificaciones y ausencias de registros',
        (tester) async {
      tester.view.physicalSize = const Size(430, 1300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repositories = _Repositories();
      final controller = repositories.controller(7);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const ResumenAcademicoPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Resumen académico'), findsOneWidget);
      expect(find.text('Hermenéutica'), findsOneWidget);
      expect(find.byKey(const Key('assignment_status_icon')), findsOneWidget);
      expect(find.text('Asignación activa'), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('resumen_estudiante_8')),
        500,
      );
      await tester.pumpAndSettle();
      final primeraTarjeta =
          tester.getRect(find.byKey(const Key('resumen_estudiante_8')));
      final segundaTarjeta =
          tester.getRect(find.byKey(const Key('resumen_estudiante_9')));
      expect(segundaTarjeta.left, primeraTarjeta.left);
      expect(segundaTarjeta.width, primeraTarjeta.width);
      expect(find.text('90 / 100 · 2 registros'), findsOneWidget);
      expect(find.text('Evaluación 1: 80 / 100'), findsOneWidget);
      expect(find.text('Evaluación 2: 100 / 100'), findsOneWidget);
      expect(find.text('Sin calificación'), findsOneWidget);
      expect(find.text('Sin asistencia'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('muestra el estado vacío sin fallar', (tester) async {
      tester.view.physicalSize = const Size(430, 1300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repositories = _Repositories(estudiantes: const []);
      final controller = repositories.controller(7);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const ResumenAcademicoPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('No hay estudiantes inscritos.'),
        500,
      );
      await tester.pumpAndSettle();
      expect(find.text('No hay estudiantes inscritos.'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

ResumenAcademico _crearResumen() => ResumenAcademico.construir(
      asignacion: _asignacion,
      estudiantes: _estudiantes,
      asistencias: _asistencias,
      calificaciones: _calificaciones,
    );

final _asignacion = AsignacionDocente(
  id: 7,
  docenteId: 'docente-1',
  docenteNombre: 'María Docente',
  docenteCorreo: 'docente@sfm.test',
  asignatura: Asignatura(
    id: 2,
    codigo: 'SFM-101',
    nombre: 'Hermenéutica',
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

const _estudiantes = [
  EstudianteInscrito(
    inscripcionId: 20,
    estudianteId: 8,
    codigo: 'EST-008',
    nombres: 'Ana',
    apellidos: 'Flores',
    ci: '123456',
    estado: true,
  ),
  EstudianteInscrito(
    inscripcionId: 21,
    estudianteId: 9,
    codigo: 'EST-009',
    nombres: 'Luis',
    apellidos: 'Rojas',
    ci: '654321',
    estado: true,
  ),
];

final _asistencias = [
  _asistencia(1, 8, EstadoAsistencia.presente),
  _asistencia(2, 8, EstadoAsistencia.presente),
  _asistencia(3, 8, EstadoAsistencia.ausente),
  _asistencia(4, 8, EstadoAsistencia.licencia),
  _asistencia(5, 999, EstadoAsistencia.presente),
];

ConsultaAsistencia _asistencia(
  int id,
  int estudianteId,
  EstadoAsistencia estado,
) =>
    ConsultaAsistencia(
      id: id,
      fecha: DateTime.utc(2026, 9, id),
      fechaRegistro: DateTime.utc(2026, 9, id),
      estado: estado,
      estudianteId: estudianteId,
      estudianteCodigo: 'EST-$estudianteId',
      estudianteNombre: estudianteId == 8 ? 'Ana Flores' : 'Otra Persona',
      estudianteCi: '$estudianteId',
      asignaturaId: 2,
      asignaturaNombre: 'Hermenéutica',
      periodoId: 3,
      periodoNombre: 'Gestión 2026',
      docenteId: 'docente-1',
      docenteNombre: 'María Docente',
    );

final _calificaciones = [
  _calificacion(1, 20, 80),
  _calificacion(2, 20, 100),
  _calificacion(3, 999, 10),
];

Calificacion _calificacion(int id, int inscripcionId, double nota) =>
    Calificacion(
      id: id,
      inscripcionId: inscripcionId,
      asignacionDocenteId: 7,
      tipoEvaluacion: 'Evaluación $id',
      nota: nota,
      fechaRegistro: DateTime.utc(2026, 9, id),
    );

class _Repositories {
  _Repositories({
    List<EstudianteInscrito> estudiantes = _estudiantes,
  })  : asignaciones = _AsignacionRepository(),
        estudiantes = _EstudianteRepository(estudiantes),
        asistencias = _AsistenciaRepository(_asistencias),
        calificaciones = _CalificacionRepository(_calificaciones);

  final _AsignacionRepository asignaciones;
  final _EstudianteRepository estudiantes;
  final _AsistenciaRepository asistencias;
  final _CalificacionRepository calificaciones;

  ResumenAcademicoController controller(int asignacionId) =>
      ResumenAcademicoController(
        asignaciones,
        estudiantes,
        asistencias,
        calificaciones,
        asignacionId,
      );
}

class _AsignacionRepository implements AsignacionDocenteRepository {
  int calls = 0;

  @override
  Future<List<AsignacionDocente>> listarPropiasActivas() async {
    calls++;
    return [_asignacion];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EstudianteRepository implements EstudianteRepository {
  _EstudianteRepository(this.items);

  final List<EstudianteInscrito> items;
  int calls = 0;
  int? requestedId;

  @override
  Future<List<EstudianteInscrito>> listarPorAsignacion(
    int asignacionId,
  ) async {
    calls++;
    requestedId = asignacionId;
    return items;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AsistenciaRepository implements ConsultaAsistenciaRepository {
  _AsistenciaRepository(this.items);

  final List<ConsultaAsistencia> items;
  int calls = 0;
  AsistenciaAdminFilter? lastFilter;

  @override
  Future<List<ConsultaAsistencia>> listar(AsistenciaAdminFilter filter) async {
    calls++;
    lastFilter = filter;
    return items;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CalificacionRepository implements CalificacionRepository {
  _CalificacionRepository(this.items);

  final List<Calificacion> items;
  int calls = 0;
  int? requestedId;

  @override
  Future<List<Calificacion>> listarPorAsignacion(int asignacionId) async {
    calls++;
    requestedId = asignacionId;
    return items;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
