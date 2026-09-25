import 'package:supabase_flutter/supabase_flutter.dart';

import 'perfil_usuario_model.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  Future<void> signIn({required String correo, required String contrasena}) {
    return _client.auth
        .signInWithPassword(email: correo.trim(), password: contrasena)
        .then((_) {});
  }

  Future<PerfilUsuario?> currentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final row = await _client
        .schema('public')
        .from('perfil_usuario')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return row == null ? null : PerfilUsuario.fromMap(row);
  }

  Future<void> signOut() => _client.auth.signOut();
}
