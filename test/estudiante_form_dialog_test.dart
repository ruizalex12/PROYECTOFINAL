import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/entities/estudiante.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/entities/estudiante_inscrito.dart';
import 'package:proyecto_final_360/features/estudiantes/domain/repositories/estudiante_repository.dart';
import 'package:proyecto_final_360/features/estudiantes/presentation/controllers/estudiante_controller.dart';
import 'package:proyecto_final_360/features/estudiantes/presentation/widgets/estudiante_form_dialog.dart';
import 'package:proyecto_final_360/features/estudiantes/presentation/widgets/estudiante_table.dart';

void main() {
  testWidgets('Cancelar cierra Nuevo estudiante sin error de tipo',
      (tester) async {
    await tester.pumpWidget(_dialogLauncher());
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo estudiante'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo estudiante'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Guardar registra y cierra el diálogo con el estudiante creado',
      (tester) async {
    await tester.pumpWidget(_dialogLauncher());
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombres *'),
      'Ana',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Apellidos *'),
      'Flores',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'CI *'), '111');
    await tester.tap(find.text('Guardar estudiante'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo estudiante'), findsNothing);
    expect(find.text('Guardado: EST0001'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Nuevo estudiante no muestra un campo editable Código',
      (tester) async {
    await tester.pumpWidget(_form());

    expect(
      find.text('El código será generado automáticamente por el sistema.'),
      findsOneWidget,
    );
    expect(
        find.byKey(const Key('estudiante-codigo-solo-lectura')), findsNothing);
    expect(
      find.widgetWithText(TextFormField, 'Código'),
      findsNothing,
    );
  });

  testWidgets('Editar estudiante muestra Código como solo lectura',
      (tester) async {
    await tester.pumpWidget(_form(estudiante: _estudiante));

    final field = tester.widget<TextFormField>(
      find.byKey(const Key('estudiante-codigo-solo-lectura')),
    );
    expect(field.enabled, isFalse);
    final editable =
        tester.widget<EditableText>(find.byType(EditableText).first);
    expect(editable.readOnly, isTrue);
    expect(find.text('EST0001'), findsOneWidget);
  });

  testWidgets('el listado mantiene visible el código generado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EstudianteTable(
            items: [_estudiante],
            onEdit: (_) {},
            onToggle: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('EST0001'), findsOneWidget);
  });
}

Widget _dialogLauncher() => MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => EstudianteController(_FakeRepository()),
        child: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                FilledButton(
                  onPressed: () async {
                    final saved = await showDialog<Estudiante>(
                      context: context,
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<EstudianteController>(),
                        child: const EstudianteFormDialog(),
                      ),
                    );
                    if (saved != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Guardado: ${saved.codigo}')),
                      );
                    }
                  },
                  child: const Text('Abrir'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

Widget _form({Estudiante? estudiante}) => MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => EstudianteController(_FakeRepository()),
        child: Scaffold(
          body: EstudianteFormDialog(estudiante: estudiante),
        ),
      ),
    );

final _estudiante = Estudiante(
  id: 1,
  codigo: 'EST0001',
  nombres: 'Ana',
  apellidos: 'Flores',
  ci: '111',
  estado: true,
  fechaRegistro: DateTime.utc(2026, 1, 1),
);

class _FakeRepository implements EstudianteRepository {
  @override
  Future<List<Estudiante>> listar({String? busqueda, bool? estado}) async =>
      [_estudiante];

  @override
  Future<Estudiante> crear({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) async =>
      _estudiante;

  @override
  Future<Estudiante> actualizar({
    required int id,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) async =>
      _estudiante;

  @override
  Future<Estudiante> cambiarEstado({
    required int id,
    required bool estado,
  }) async =>
      _estudiante;

  @override
  Future<int> contarActivos() async => 1;

  @override
  Future<List<EstudianteInscrito>> listarPorAsignacion(
    int asignacionId,
  ) async =>
      const [];
}
