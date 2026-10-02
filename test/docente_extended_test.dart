import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_360/features/docentes/data/datasources/docente_remote_datasource.dart';
import 'package:proyecto_final_360/features/docentes/data/models/docente_model.dart';
import 'package:proyecto_final_360/features/docentes/domain/entities/docente.dart';
import 'package:proyecto_final_360/features/docentes/domain/repositories/docente_repository.dart';
import 'package:proyecto_final_360/features/docentes/presentation/controllers/docente_controller.dart';
import 'package:proyecto_final_360/features/docentes/presentation/widgets/docente_detail_dialog.dart';
import 'package:proyecto_final_360/features/docentes/presentation/widgets/docente_form_dialog.dart';
import 'package:proyecto_final_360/features/docentes/presentation/widgets/docente_table.dart';

void main() {
  test('modelo combina perfil_usuario con datos_docente', () {
    final model = DocenteModel.fromMap({
      'id': 'd1',
      'correo': 'ana@sfm.test',
      'nombres': 'Ana',
      'apellidos': 'Flores',
      'ci': '111',
      'telefono': '70000000',
      'direccion': 'Calle 1',
      'sexo': 'FEMENINO',
      'fecha_nacimiento': '1990-05-20',
      'estado': true,
      'fecha_registro': '2026-01-01T00:00:00Z',
      'datos_docente': {
        'especialidad': 'Teología',
        'titulo_profesional': 'Licenciada',
        'grado_academico': 'Licenciatura',
        'fecha_incorporacion': '2020-02-10',
        'observaciones': 'Tiempo completo',
      },
    });
    expect(model.direccion, 'Calle 1');
    expect(model.fechaNacimiento, DateTime(1990, 5, 20));
    expect(model.especialidad, 'Teología');
    expect(model.fechaIncorporacion, DateTime(2020, 2, 10));
  });

  test('modelo acepta docente antiguo sin datos profesionales', () {
    final model = DocenteModel.fromMap({
      'id': 'd2',
      'correo': 'antiguo@sfm.test',
      'nombres': 'Luis',
      'apellidos': 'Rojas',
      'ci': '222',
      'estado': true,
      'fecha_registro': '2026-01-01T00:00:00Z',
      'datos_docente': null,
    });
    expect(model.especialidad, isNull);
    expect(model.fechaNacimiento, isNull);
  });

  test('construye UPDATE de perfil y UPSERT profesional', () {
    final profile = DocenteRemoteDatasource.buildProfileUpdate(
      nombres: 'Ana',
      apellidos: 'Flores',
      ci: '111',
      telefono: '70000000',
      direccion: 'Calle 1',
      sexo: 'FEMENINO',
      fechaNacimiento: DateTime(1990, 5, 20),
    );
    final professional = DocenteRemoteDatasource.buildProfessionalUpsert(
      id: 'd1',
      especialidad: 'Teología',
      tituloProfesional: 'Licenciada',
      fechaIncorporacion: DateTime(2020, 2, 10),
    );
    expect(profile['fecha_nacimiento'], '1990-05-20');
    expect(profile['sexo'], 'FEMENINO');
    expect(professional['usuario_id'], 'd1');
    expect(professional['especialidad'], 'Teología');
    expect(professional['fecha_incorporacion'], '2020-02-10');
  });

  testWidgets('tabla muestra especialidad y acciones', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DocenteTable(
          items: [_complete],
          onView: (_) {},
          onEdit: (_) {},
          onToggle: (_) {},
        ),
      ),
    ));
    expect(find.text('Teología'), findsOneWidget);
    expect(find.byTooltip('Ver detalle del docente'), findsOneWidget);
    expect(find.byTooltip('Editar docente'), findsOneWidget);
    expect(find.byTooltip('Desactivar docente'), findsOneWidget);
    expect(
      tester.getTopRight(find.byTooltip('Desactivar docente')).dx,
      lessThanOrEqualTo(1280),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('detalle muestra información completa', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DocenteDetailDialog(docente: _complete)),
    ));
    expect(find.text('DATOS PERSONALES'), findsOneWidget);
    expect(find.text('DATOS PROFESIONALES'), findsOneWidget);
    expect(find.text('Calle 1'), findsOneWidget);
    expect(find.text('Teología'), findsOneWidget);
    expect(find.text('Tiempo completo'), findsOneWidget);
  });

  testWidgets('detalle se adapta a pantalla angosta sin desbordar',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DocenteDetailDialog(docente: _complete)),
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('DATOS PROFESIONALES'), findsOneWidget);
  });

  testWidgets('edición carga datos y bloquea correo y rol', (tester) async {
    await _pumpForm(tester, _complete);
    expect(_text(tester, 'docente_nombres'), 'Ana');
    expect(_text(tester, 'docente_direccion'), 'Calle 1');
    expect(_text(tester, 'docente_especialidad'), 'Teología');
    expect(_text(tester, 'docente_titulo_profesional'), 'Licenciada');
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('docente_correo_solo_lectura')),
          )
          .enabled,
      isFalse,
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('docente_rol_solo_lectura')),
          )
          .enabled,
      isFalse,
    );
  });

  testWidgets('especialidad, sexo y fecha de nacimiento son obligatorios',
      (tester) async {
    await _pumpForm(tester, _legacy);
    await tester.ensureVisible(find.byKey(const Key('docente_guardar')));
    await tester.tap(find.byKey(const Key('docente_guardar')));
    await tester.pump();
    expect(find.text('Ingresa la especialidad del docente.'), findsOneWidget);
    expect(find.text('Selecciona Masculino o Femenino.'), findsOneWidget);
    expect(find.text('Selecciona la fecha de nacimiento.'), findsOneWidget);
  });
}

String _text(WidgetTester tester, String key) =>
    tester.widget<TextFormField>(find.byKey(Key(key))).controller!.text;

Future<void> _pumpForm(WidgetTester tester, Docente docente) =>
    tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DocenteController(_Repository()),
        child: MaterialApp(
          home: Scaffold(body: DocenteFormDialog(docente: docente)),
        ),
      ),
    );

final _complete = Docente(
  id: 'd1',
  correo: 'ana@sfm.test',
  nombres: 'Ana',
  apellidos: 'Flores',
  ci: '111',
  telefono: '70000000',
  direccion: 'Calle 1',
  sexo: 'FEMENINO',
  fechaNacimiento: DateTime(1990, 5, 20),
  especialidad: 'Teología',
  tituloProfesional: 'Licenciada',
  gradoAcademico: 'Licenciatura',
  fechaIncorporacion: DateTime(2020, 2, 10),
  observaciones: 'Tiempo completo',
  estado: true,
  fechaRegistro: DateTime(2026),
);

final _legacy = Docente(
  id: 'd2',
  correo: 'legacy@sfm.test',
  nombres: 'Luis',
  apellidos: 'Rojas',
  ci: '222',
  estado: true,
  fechaRegistro: DateTime(2026),
);

class _Repository implements DocenteRepository {
  @override
  Future<List<Docente>> listar({String? busqueda, bool? estado}) async =>
      [_complete];

  @override
  Future<Docente> actualizar({
    required String id,
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
    String? observaciones,
  }) async =>
      _complete;

  @override
  Future<Docente> cambiarEstado(
          {required String id, required bool estado}) async =>
      _complete;
}
