import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_360/features/usuarios/data/datasources/usuario_remote_datasource.dart';
import 'package:proyecto_final_360/features/usuarios/domain/entities/usuario.dart';
import 'package:proyecto_final_360/features/usuarios/domain/repositories/usuario_repository.dart';
import 'package:proyecto_final_360/features/usuarios/presentation/controllers/usuario_controller.dart';
import 'package:proyecto_final_360/features/usuarios/presentation/widgets/usuario_form_dialog.dart';
import 'package:proyecto_final_360/features/usuarios/presentation/widgets/usuario_table.dart';

void main() {
  testWidgets('tabla de usuarios mantiene visibles todas las acciones',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: UsuarioTable(
          items: [
            Usuario(
              id: 'u1',
              correo: 'docente.demo3@sfm.test',
              nombres: 'Docente',
              apellidos: 'Demo 3',
              ci: '989898',
              rol: UsuarioRol.docente,
              estado: true,
              fechaRegistro: DateTime(2026, 10, 1),
            ),
          ],
          onEdit: (_) {},
          onToggle: (_) {},
        ),
      ),
    ));

    final lastAction = find.byTooltip('Desactivar usuario');
    expect(find.byTooltip('Editar usuario'), findsOneWidget);
    expect(lastAction, findsOneWidget);
    expect(tester.getTopRight(lastAction).dx, lessThanOrEqualTo(1280));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Nuevo usuario abre el formulario común', (tester) async {
    await _pumpHarness(tester);
    await tester.tap(find.text('Nuevo usuario'));
    await tester.pumpAndSettle();

    expect(find.text('DATOS PERSONALES'), findsOneWidget);
    expect(find.text('DATOS DE ACCESO'), findsOneWidget);
    expect(find.byKey(const Key('usuario-seccion-docente')), findsNothing);
  });

  testWidgets('ADMINISTRADOR no muestra información profesional',
      (tester) async {
    await _openForm(tester);
    await _selectRole(tester, 'Administrador');
    expect(find.byKey(const Key('usuario-seccion-docente')), findsNothing);
  });

  testWidgets('DOCENTE muestra información profesional y exige especialidad',
      (tester) async {
    await _openForm(tester);
    await _selectRole(tester, 'Docente');
    expect(find.byKey(const Key('usuario-seccion-docente')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('usuario-guardar')));
    await tester.tap(find.byKey(const Key('usuario-guardar')));
    await tester.pump();
    expect(find.text('Ingrese la especialidad del docente.'), findsOneWidget);
    expect(find.text('Seleccione Masculino o Femenino.'), findsOneWidget);
    expect(find.text('Seleccione la fecha de nacimiento.'), findsOneWidget);
  });

  testWidgets('formulario DOCENTE se adapta a pantalla angosta sin desbordar',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _openForm(tester);
    await _selectRole(tester, 'Docente');
    await tester.ensureVisible(
      find.byKey(const Key('usuario-seccion-docente')),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('usuario-seccion-docente')), findsOneWidget);
  });

  testWidgets('DOCENTE solo ofrece Masculino y Femenino', (tester) async {
    await _openForm(tester);
    await _selectRole(tester, 'Docente');
    final sexo = find.byKey(const Key('usuario-sexo-DOCENTE'));
    await tester.ensureVisible(sexo);
    await tester.tap(sexo);
    await tester.pumpAndSettle();
    expect(find.text('Masculino'), findsOneWidget);
    expect(find.text('Femenino'), findsOneWidget);
    expect(find.text('Otro'), findsNothing);
  });

  testWidgets('ADMINISTRADOR conserva sexo opcional y opción Otro',
      (tester) async {
    await _openForm(tester);
    await _selectRole(tester, 'Administrador');
    final sexo = find.byKey(const Key('usuario-sexo-ADMINISTRADOR'));
    await tester.ensureVisible(sexo);
    await tester.tap(sexo);
    await tester.pumpAndSettle();
    expect(find.text('Otro'), findsOneWidget);
    await tester.tap(find.text('Otro'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('usuario-guardar')));
    await tester.tap(find.byKey(const Key('usuario-guardar')));
    await tester.pump();
    expect(find.text('Seleccione Masculino o Femenino.'), findsNothing);
    expect(find.text('Seleccione la fecha de nacimiento.'), findsNothing);
  });

  testWidgets('cambiar DOCENTE a ADMINISTRADOR oculta y limpia especialidad',
      (tester) async {
    await _openForm(tester);
    await _selectRole(tester, 'Docente');
    await tester.enterText(
      find.byKey(const Key('usuario-especialidad')),
      'Teología',
    );
    await _selectRole(tester, 'Administrador');
    expect(find.byKey(const Key('usuario-seccion-docente')), findsNothing);

    await _selectRole(tester, 'Docente');
    final field = tester.widget<TextFormField>(
      find.byKey(const Key('usuario-especialidad')),
    );
    expect(field.controller?.text, isEmpty);
  });

  test('payload ADMINISTRADOR no contiene docente y mapea datos personales',
      () {
    final payload = UsuarioRemoteDatasource.buildCreatePayload(
      nombres: 'Ana',
      apellidos: 'Admin',
      ci: '123',
      telefono: '70000000',
      direccion: 'Calle 1',
      sexo: SexoUsuario.femenino,
      fechaNacimiento: '1990-05-20',
      correo: 'ana@example.com',
      contrasena: 'Segura123',
      rol: UsuarioRol.administrador,
    );

    expect(payload.containsKey('docente'), isFalse);
    expect(payload['direccion'], 'Calle 1');
    expect(payload['sexo'], 'FEMENINO');
    expect(payload['fechaNacimiento'], '1990-05-20');
    expect(payload['password'], 'Segura123');
  });

  test('payload DOCENTE contiene el objeto profesional', () {
    final payload = UsuarioRemoteDatasource.buildCreatePayload(
      nombres: 'Luis',
      apellidos: 'Docente',
      ci: '456',
      correo: 'luis@example.com',
      contrasena: 'Segura123',
      rol: UsuarioRol.docente,
      docente: const DatosDocenteCreacion(
        especialidad: 'Biblia',
        tituloProfesional: 'Licenciado',
        gradoAcademico: 'Licenciatura',
        fechaIncorporacion: '2026-01-10',
        observaciones: 'Tiempo completo',
      ),
    );

    expect(payload['rol'], 'DOCENTE');
    expect(payload['docente'], {
      'especialidad': 'Biblia',
      'tituloProfesional': 'Licenciado',
      'gradoAcademico': 'Licenciatura',
      'fechaIncorporacion': '2026-01-10',
      'observaciones': 'Tiempo completo',
    });
  });
}

Future<void> _pumpHarness(WidgetTester tester) async {
  final controller =
      UsuarioController(_FakeRepository(), currentUserId: 'admin');
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider.value(
        value: controller,
        child: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => ChangeNotifierProvider.value(
                    value: controller,
                    child: const UsuarioFormDialog(),
                  ),
                ),
                child: const Text('Nuevo usuario'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openForm(WidgetTester tester) async {
  await _pumpHarness(tester);
  await tester.tap(find.text('Nuevo usuario'));
  await tester.pumpAndSettle();
}

Future<void> _selectRole(WidgetTester tester, String label) async {
  final role = find.byKey(const Key('usuario-rol'));
  await tester.ensureVisible(role);
  await tester.tap(role);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

class _FakeRepository implements UsuarioRepository {
  @override
  Future<List<Usuario>> listar({
    String? busqueda,
    UsuarioRol? rol,
    bool? estado,
  }) async =>
      [];

  @override
  Future<Usuario> crear({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
    String? direccion,
    SexoUsuario? sexo,
    String? fechaNacimiento,
    required String correo,
    required String contrasena,
    required UsuarioRol rol,
    DatosDocenteCreacion? docente,
  }) async =>
      _usuario;

  @override
  Future<Usuario> actualizar({
    required String id,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) async =>
      _usuario;

  @override
  Future<Usuario> cambiarEstado(
          {required String id, required bool estado}) async =>
      _usuario;
}

final _usuario = Usuario(
  id: 'usuario-1',
  correo: 'usuario@example.com',
  nombres: 'Usuario',
  apellidos: 'Prueba',
  ci: '123',
  rol: UsuarioRol.administrador,
  estado: true,
  fechaRegistro: DateTime(2026),
);
