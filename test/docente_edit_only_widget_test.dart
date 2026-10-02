import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_360/features/docentes/domain/entities/docente.dart';
import 'package:proyecto_final_360/features/docentes/domain/repositories/docente_repository.dart';
import 'package:proyecto_final_360/features/docentes/presentation/controllers/docente_controller.dart';
import 'package:proyecto_final_360/features/docentes/presentation/widgets/docente_form_dialog.dart';

void main() {
  testWidgets('formulario Docentes es exclusivamente de edición',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DocenteController(_Repository()),
        child: MaterialApp(
            home: Scaffold(body: DocenteFormDialog(docente: _docente))),
      ),
    );

    expect(find.text('Editar docente'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);
    expect(find.text('Nuevo docente'), findsNothing);
    expect(find.text('Crear docente'), findsNothing);
    expect(find.textContaining('Contraseña'), findsNothing);
    final correo = tester.widget<TextFormField>(
        find.byKey(const Key('docente_correo_solo_lectura')));
    expect(correo.enabled, isFalse);
  });
}

final _docente = Docente(
    id: 'd1',
    correo: 'docente@sfm.test',
    nombres: 'Ana',
    apellidos: 'Flores',
    ci: '1',
    sexo: 'FEMENINO',
    fechaNacimiento: DateTime(1990),
    especialidad: 'Teología',
    estado: true,
    fechaRegistro: DateTime(2026));

class _Repository implements DocenteRepository {
  @override
  Future<List<Docente>> listar({String? busqueda, bool? estado}) async =>
      [_docente];
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
          String? observaciones}) async =>
      _docente;
  @override
  Future<Docente> cambiarEstado(
          {required String id, required bool estado}) async =>
      _docente;
}
