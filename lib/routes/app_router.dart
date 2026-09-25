import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/asignaturas/domain/repositories/asignatura_repository.dart';
import '../features/asignaturas/presentation/controllers/asignatura_controller.dart';
import '../features/asignaturas/presentation/pages/asignaturas_page.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/auth_gate_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/admin_dashboard_page.dart';
import '../features/dashboard/presentation/docente_dashboard_page.dart';
import 'route_guard.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter({required this.auth, required this.asignaturas});

  final AuthController auth;
  final AsignaturaRepository asignaturas;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final guard = RouteGuard(auth);
    final page = switch (settings.name) {
      RouteNames.root => const AuthGatePage(),
      RouteNames.login => guard.hasSession
          ? (guard.isAdmin
              ? const AdminDashboardPage()
              : const DocenteDashboardPage())
          : const LoginPage(),
      RouteNames.admin => guard.isAdmin
          ? const AdminDashboardPage()
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.adminAsignaturas => guard.isAdmin
          ? ChangeNotifierProvider(
              create: (_) => AsignaturaController(asignaturas),
              child: const AsignaturasPage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.docente => guard.isDocente
          ? const DocenteDashboardPage()
          : _UnauthorizedPage(authenticated: guard.hasSession),
      _ => const _NotFoundPage(),
    };

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => page,
    );
  }
}

class _UnauthorizedPage extends StatelessWidget {
  const _UnauthorizedPage({required this.authenticated});

  final bool authenticated;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64),
                const SizedBox(height: 16),
                Text(
                  authenticated
                      ? 'No tiene permisos para acceder a esta pagina.'
                      : 'Debe iniciar sesion para continuar.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    authenticated ? RouteNames.root : RouteNames.login,
                    (_) => false,
                  ),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        ),
      );
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pagina no encontrada')),
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.root,
              (_) => false,
            ),
            child: const Text('Volver al inicio'),
          ),
        ),
      );
}
