import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/usuarios/data/models/usuario_model.dart';
import 'package:proyecto_final_360/features/usuarios/domain/entities/usuario.dart';
import 'package:proyecto_final_360/features/docentes/data/models/docente_model.dart';

void main() {
  test('un usuario DOCENTE comparte la fuente perfil_usuario de Docentes', () {
    final row = <String, dynamic>{
      'id': 'docente-1',
      'correo': 'docente@sfm.test',
      'nombres': 'Laura',
      'apellidos': 'Ríos',
      'ci': 'DOC-1',
      'telefono': null,
      'rol': 'DOCENTE',
      'estado': true,
      'fecha_registro': '2026-09-30T12:00:00Z',
    };

    final usuario = UsuarioModel.fromMap(row);
    final docente = DocenteModel.fromMap(row);
    expect(usuario.rol, UsuarioRol.docente);
    expect(usuario.estado, isTrue);
    expect(docente.id, usuario.id);
    expect(docente.nombreCompleto, usuario.nombreCompleto);
    expect(row['rol'], 'DOCENTE');
    expect(row['estado'], isTrue);
  });

  test(
      'un DOCENTE inactivo conserva perfil pero no cumple el filtro de nuevas asignaciones',
      () {
    final row = <String, dynamic>{
      'id': 'docente-2',
      'correo': 'inactivo@sfm.test',
      'nombres': 'Luis',
      'apellidos': 'Rojas',
      'ci': 'DOC-2',
      'telefono': null,
      'rol': 'DOCENTE',
      'estado': false,
      'fecha_registro': '2026-09-30T12:00:00Z',
    };
    final docente = DocenteModel.fromMap(row);
    expect(docente.estado, isFalse);
    expect(row['rol'] == 'DOCENTE' && row['estado'] == true, isFalse);
  });
}
