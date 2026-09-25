import '../features/auth/data/perfil_usuario_model.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';

class RouteGuard {
  const RouteGuard(this.auth);

  final AuthController auth;

  bool get hasSession => auth.status == AuthStatus.authenticated;
  bool get isAdmin =>
      hasSession && auth.profile?.rol == RolUsuario.administrador;
  bool get isDocente => hasSession && auth.profile?.rol == RolUsuario.docente;
}
