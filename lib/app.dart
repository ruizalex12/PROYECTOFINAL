import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'controllers/preferences_controller.dart';
import 'screens/auth_gate.dart';

import 'screens/setup_required_screen.dart';

class ProyectoFinalApp extends StatelessWidget {
  const ProyectoFinalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesController>();
    final config = context.watch<AppConfig>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduGestión 360',
      themeMode: prefs.themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: config.hasSupabaseConfig || config.demoMode
          ? const AuthGate()
          : const SetupRequiredScreen(),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
        seedColor: const Color(0xFF3157D5), brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF6F7FC)
          : const Color(0xFF101218),
      appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          centerTitle: false),
      cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerLowest,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none)),
      navigationBarTheme: NavigationBarThemeData(
          height: 72,
          indicatorColor: scheme.primaryContainer,
          labelTextStyle: WidgetStatePropertyAll(
              TextStyle(fontSize: 12, color: scheme.onSurface))),
    );
  }
}
