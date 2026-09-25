import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/asignaturas/domain/repositories/asignatura_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'routes/app_router.dart';
import 'routes/route_names.dart';

class ProyectoFinalApp extends StatelessWidget {
  const ProyectoFinalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final auth = context.watch<AuthController>();
    final asignaturas = context.read<AsignaturaRepository>();
    final router = AppRouter(auth: auth, asignaturas: asignaturas);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduGestion 360',
      themeMode: theme.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      initialRoute: RouteNames.root,
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}

class SetupRequiredApp extends StatelessWidget {
  const SetupRequiredApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings_outlined, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Configuracion requerida',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Configure SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY mediante --dart-define.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
