import '../entities/usuario.dart';

abstract interface class UsuarioRepository {
  Future<List<Usuario>> listar({
    String? busqueda,
    UsuarioRol? rol,
    bool? estado,
  });

  Future<Usuario> crear({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
    required String correo,
    required String contrasena,
    required UsuarioRol rol,
  });

  Future<Usuario> actualizar({
    required String id,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  });

  Future<Usuario> cambiarEstado({required String id, required bool estado});
}
