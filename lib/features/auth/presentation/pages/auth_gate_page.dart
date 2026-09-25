import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/app_states.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return switch (auth.status) {
      AuthStatus.loading => const Scaffold(
          body: AppLoadingState(message: 'Validando sesion...'),
        ),
      AuthStatus.unauthenticated => const LoginPage(),
      AuthStatus.failure => Scaffold(
          body: AppErrorState(
            message: auth.errorMessage ?? 'No fue posible validar la sesion.',
            onRetry: auth.refresh,
          ),
        ),
      AuthStatus.authenticated => _Redirect(
          route: auth.isAdmin ? RouteNames.admin : RouteNames.docente,
        ),
    };
  }
}

class _Redirect extends StatefulWidget {
  const _Redirect({required this.route});

  final String route;

  @override
  State<_Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<_Redirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, widget.route, (_) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: AppLoadingState(message: 'Preparando su espacio...'),
      );
}
