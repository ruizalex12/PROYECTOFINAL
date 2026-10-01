import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/asignaturas/domain/repositories/asignatura_repository.dart';
import 'features/asistencia/domain/repositories/asistencia_repository.dart';
import 'features/asistencias_admin/domain/repositories/consulta_asistencia_repository.dart';
import 'features/asignaciones_docente/domain/repositories/asignacion_docente_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/calificaciones/domain/repositories/calificacion_repository.dart';
import 'features/calificaciones_admin/domain/repositories/consulta_calificacion_repository.dart';
import 'features/estudiantes/domain/repositories/estudiante_repository.dart';
import 'features/periodos/domain/repositories/periodo_academico_repository.dart';
import 'features/inscripciones/domain/repositories/inscripcion_repository.dart';
import 'features/docentes/domain/repositories/docente_repository.dart';
import 'features/usuarios/domain/repositories/usuario_repository.dart';
import 'features/reportes/domain/repositories/reporte_repository.dart';
import 'routes/app_router.dart';
import 'routes/route_names.dart';

class ProyectoFinalApp extends StatelessWidget {
  const ProyectoFinalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final auth = context.watch<AuthController>();
    final asignaturas = context.read<AsignaturaRepository>();
    final asignacionesDocente = context.read<AsignacionDocenteRepository>();
    final estudiantes = context.read<EstudianteRepository>();
    final asistencias = context.read<AsistenciaRepository>();
    final consultaAsistencias = context.read<ConsultaAsistenciaRepository>();
    final calificaciones = context.read<CalificacionRepository>();
    final consultaCalificaciones =
        context.read<ConsultaCalificacionRepository>();
    final periodos = context.read<PeriodoAcademicoRepository>();
    final inscripciones = context.read<InscripcionRepository>();
    final docentes = context.read<DocenteRepository>();
    final usuarios = context.read<UsuarioRepository>();
    final reportes = context.read<ReporteRepository>();
    final router = AppRouter(
      auth: auth,
      asignaturas: asignaturas,
      asignacionesDocente: asignacionesDocente,
      estudiantes: estudiantes,
      asistencias: asistencias,
      consultaAsistencias: consultaAsistencias,
      calificaciones: calificaciones,
      consultaCalificaciones: consultaCalificaciones,
      periodos: periodos,
      inscripciones: inscripciones,
      docentes: docentes,
      usuarios: usuarios,
      reportes: reportes,
    );

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
