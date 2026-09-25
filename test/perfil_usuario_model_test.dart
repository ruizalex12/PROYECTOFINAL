import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/auth/data/perfil_usuario_model.dart';

void main() {
  test('acepta un perfil ADMINISTRADOR activo', () {
    final profile = PerfilUsuario.fromMap({
      'id': 'abc',
      'correo': 'admin@example.com',
      'nombres': 'Ana',
      'apellidos': 'Prueba',
      'ci': 'CI-001',
      'telefono': null,
      'rol': 'ADMINISTRADOR',
      'estado': true,
      'fecha_registro': '2026-09-25T12:00:00Z',
    });

    expect(profile.rol, RolUsuario.administrador);
    expect(profile.estado, isTrue);
    expect(profile.nombreCompleto, 'Ana Prueba');
  });

  test('rechaza roles fuera del alcance definitivo', () {
    expect(
      () => PerfilUsuario.fromMap({
        'id': 'abc',
        'correo': 'student@example.com',
        'nombres': 'Usuario',
        'apellidos': 'Antiguo',
        'ci': 'CI-002',
        'rol': 'ESTUDIANTE',
        'estado': true,
        'fecha_registro': '2026-09-25T12:00:00Z',
      }),
      throwsFormatException,
    );
  });
}
