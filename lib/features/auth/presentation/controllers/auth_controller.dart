import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../data/auth_repository_impl.dart';
import '../../data/perfil_usuario_model.dart';

enum AuthStatus { loading, unauthenticated, authenticated, failure }

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    _subscription = _repository.authChanges.listen(_onAuthStateChanged);
    refresh();
  }

  final AuthRepositoryImpl _repository;
  StreamSubscription<AuthState>? _subscription;

  AuthStatus _status = AuthStatus.loading;
  PerfilUsuario? _profile;
  String? _errorMessage;
  bool _submitting = false;

  AuthStatus get status => _status;
  PerfilUsuario? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get submitting => _submitting;
  bool get isAdmin => _profile?.rol == RolUsuario.administrador;
  bool get isDocente => _profile?.rol == RolUsuario.docente;

  void _onAuthStateChanged(AuthState state) {
    if (state.event != AuthChangeEvent.signedOut) return;
    _profile = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (!_repository.hasSession) {
      _profile = null;
      _errorMessage = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await _repository.requireCurrentProfile();
      _status = AuthStatus.authenticated;
    } catch (error) {
      _profile = null;
      _errorMessage = ErrorMapper.message(error);
      await _repository.signOut();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn({
    required String correo,
    required String contrasena,
  }) async {
    _submitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.signIn(correo: correo, contrasena: contrasena);
      await refresh();
      return _status == AuthStatus.authenticated;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _status = AuthStatus.unauthenticated;
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _profile = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
