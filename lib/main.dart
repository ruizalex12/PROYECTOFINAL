import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/preferences_service.dart';
import 'core/theme/theme_controller.dart';
import 'features/asignaturas/data/datasources/asignatura_remote_datasource.dart';
import 'features/asignaturas/data/repositories/asignatura_repository_impl.dart';
import 'features/asignaturas/domain/repositories/asignatura_repository.dart';
import 'features/auth/data/auth_remote_datasource.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  if (!config.isComplete) {
    runApp(const SetupRequiredApp());
    return;
  }

  await Supabase.initialize(
    url: config.supabaseUrl,
    publishableKey: config.supabasePublishableKey,
  );

  final preferences = await SharedPreferences.getInstance();
  final client = Supabase.instance.client;
  final authRepository = AuthRepositoryImpl(AuthRemoteDatasource(client));
  final asignaturaRepository =
      AsignaturaRepositoryImpl(AsignaturaRemoteDatasource(client));

  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: config),
        ChangeNotifierProvider(
          create: (_) => ThemeController(PreferencesService(preferences)),
        ),
        Provider<AsignaturaRepository>.value(value: asignaturaRepository),
        ChangeNotifierProvider(
          create: (_) => AuthController(authRepository),
        ),
      ],
      child: const ProyectoFinalApp(),
    ),
  );
}
