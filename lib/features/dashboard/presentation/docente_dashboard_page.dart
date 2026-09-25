import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../../routes/route_names.dart';

class DocenteDashboardPage extends StatelessWidget {
  const DocenteDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Docente'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.login,
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.co_present_rounded, size: 64),
              const SizedBox(height: 16),
              Text(
                'Bienvenido, ${auth.profile?.nombreCompleto ?? 'Docente'}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Los modulos de asistencia y calificaciones se habilitaran en la siguiente etapa.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
