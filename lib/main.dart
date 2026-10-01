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
import 'features/asistencia/data/datasources/asistencia_remote_datasource.dart';
import 'features/asistencia/data/repositories/asistencia_repository_impl.dart';
import 'features/asistencia/domain/repositories/asistencia_repository.dart';
import 'features/asistencias_admin/data/datasources/consulta_asistencia_remote_datasource.dart';
import 'features/asistencias_admin/data/repositories/consulta_asistencia_repository_impl.dart';
import 'features/asistencias_admin/domain/repositories/consulta_asistencia_repository.dart';
import 'features/asignaciones_docente/data/datasources/asignacion_docente_remote_datasource.dart';
import 'features/asignaciones_docente/data/repositories/asignacion_docente_repository_impl.dart';
import 'features/asignaciones_docente/domain/repositories/asignacion_docente_repository.dart';
import 'features/auth/data/auth_remote_datasource.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/calificaciones/data/datasources/calificacion_remote_datasource.dart';
import 'features/calificaciones/data/repositories/calificacion_repository_impl.dart';
import 'features/calificaciones/domain/repositories/calificacion_repository.dart';
import 'features/calificaciones_admin/data/datasources/consulta_calificacion_remote_datasource.dart';
import 'features/calificaciones_admin/data/repositories/consulta_calificacion_repository_impl.dart';
import 'features/calificaciones_admin/domain/repositories/consulta_calificacion_repository.dart';
import 'features/estudiantes/data/datasources/estudiante_remote_datasource.dart';
import 'features/estudiantes/data/repositories/estudiante_repository_impl.dart';
import 'features/estudiantes/domain/repositories/estudiante_repository.dart';
import 'features/periodos/data/datasources/periodo_academico_remote_datasource.dart';
import 'features/periodos/data/repositories/periodo_academico_repository_impl.dart';
import 'features/periodos/domain/repositories/periodo_academico_repository.dart';
import 'features/inscripciones/data/datasources/inscripcion_remote_datasource.dart';
import 'features/inscripciones/data/repositories/inscripcion_repository_impl.dart';
import 'features/inscripciones/domain/repositories/inscripcion_repository.dart';
import 'features/docentes/data/datasources/docente_remote_datasource.dart';
import 'features/docentes/data/repositories/docente_repository_impl.dart';
import 'features/docentes/domain/repositories/docente_repository.dart';
import 'features/usuarios/data/datasources/usuario_remote_datasource.dart';
import 'features/usuarios/data/repositories/usuario_repository_impl.dart';
import 'features/usuarios/domain/repositories/usuario_repository.dart';
import 'features/reportes/data/datasources/reporte_remote_datasource.dart';
import 'features/reportes/data/repositories/reporte_repository_impl.dart';
import 'features/reportes/domain/repositories/reporte_repository.dart';

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
  final asignacionDocenteRepository = AsignacionDocenteRepositoryImpl(
    AsignacionDocenteRemoteDatasource(client),
  );
  final estudianteRepository =
      EstudianteRepositoryImpl(EstudianteRemoteDatasource(client));
  final asistenciaRepository =
      AsistenciaRepositoryImpl(AsistenciaRemoteDatasource(client));
  final consultaAsistenciaRepository = ConsultaAsistenciaRepositoryImpl(
    ConsultaAsistenciaRemoteDatasource(client),
  );
  final calificacionRepository =
      CalificacionRepositoryImpl(CalificacionRemoteDatasource(client));
  final consultaCalificacionRepository = ConsultaCalificacionRepositoryImpl(
    ConsultaCalificacionRemoteDatasource(client),
  );
  final periodoRepository = PeriodoAcademicoRepositoryImpl(
    PeriodoAcademicoRemoteDatasource(client),
  );
  final inscripcionRepository =
      InscripcionRepositoryImpl(InscripcionRemoteDatasource(client));
  final docenteRepository =
      DocenteRepositoryImpl(DocenteRemoteDatasource(client));
  final usuarioRepository =
      UsuarioRepositoryImpl(UsuarioRemoteDatasource(client));
  final reporteRepository = ReporteRepositoryImpl(
    ReporteRemoteDatasource(client),
    consultaAsistenciaRepository,
    consultaCalificacionRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: config),
        ChangeNotifierProvider(
          create: (_) => ThemeController(PreferencesService(preferences)),
        ),
        Provider<AsignaturaRepository>.value(value: asignaturaRepository),
        Provider<AsignacionDocenteRepository>.value(
          value: asignacionDocenteRepository,
        ),
        Provider<EstudianteRepository>.value(value: estudianteRepository),
        Provider<AsistenciaRepository>.value(value: asistenciaRepository),
        Provider<ConsultaAsistenciaRepository>.value(
          value: consultaAsistenciaRepository,
        ),
        Provider<CalificacionRepository>.value(value: calificacionRepository),
        Provider<ConsultaCalificacionRepository>.value(
          value: consultaCalificacionRepository,
        ),
        Provider<PeriodoAcademicoRepository>.value(value: periodoRepository),
        Provider<InscripcionRepository>.value(value: inscripcionRepository),
        Provider<DocenteRepository>.value(value: docenteRepository),
        Provider<UsuarioRepository>.value(value: usuarioRepository),
        Provider<ReporteRepository>.value(value: reporteRepository),
        ChangeNotifierProvider(
          create: (_) => AuthController(authRepository),
        ),
      ],
      child: const ProyectoFinalApp(),
    ),
  );
}
