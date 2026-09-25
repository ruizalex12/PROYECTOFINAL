import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import 'auth_remote_datasource.dart';
import 'perfil_usuario_model.dart';

class AuthRepositoryImpl {
  AuthRepositoryImpl(this._datasource);

  final AuthRemoteDatasource _datasource;

  bool get hasSession => _datasource.currentUser != null;
  Stream<AuthState> get authChanges => _datasource.authChanges;

  Future<void> signIn({required String correo, required String contrasena}) {
    return _datasource.signIn(correo: correo, contrasena: contrasena);
  }

  Future<PerfilUsuario> requireCurrentProfile() async {
    final profile = await _datasource.currentProfile();
    if (profile == null) {
      throw const AppException(
        'La cuenta no tiene un perfil habilitado en el sistema.',
      );
    }
    if (!profile.estado) {
      throw const AppException(
        'Su cuenta se encuentra inactiva. Contacte al administrador.',
      );
    }
    return profile;
  }

  Future<void> signOut() => _datasource.signOut();
}
