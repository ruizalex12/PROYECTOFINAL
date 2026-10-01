import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/asignaturas/domain/repositories/asignatura_repository.dart';
import '../features/asignaturas/presentation/controllers/asignatura_controller.dart';
import '../features/asignaturas/presentation/pages/asignaturas_page.dart';
import '../features/asistencia/domain/repositories/asistencia_repository.dart';
import '../features/asistencia/presentation/controllers/asistencia_controller.dart';
import '../features/asistencia/presentation/pages/asistencia_page.dart';
import '../features/asistencias_admin/domain/repositories/consulta_asistencia_repository.dart';
import '../features/asistencias_admin/presentation/controllers/consulta_asistencia_controller.dart';
import '../features/asistencias_admin/presentation/pages/consulta_asistencia_page.dart';
import '../features/asignaciones_docente/domain/repositories/asignacion_docente_repository.dart';
import '../features/asignaciones_docente/presentation/controllers/mis_asignaturas_controller.dart';
import '../features/asignaciones_docente/presentation/controllers/asignacion_docente_controller.dart';
import '../features/asignaciones_docente/presentation/pages/asignaciones_docente_page.dart';
import '../features/asignaciones_docente/presentation/pages/mis_asignaturas_page.dart';
import '../features/asignaciones_docente/domain/entities/asignacion_docente.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/auth_gate_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/calificaciones/domain/repositories/calificacion_repository.dart';
import '../features/calificaciones/presentation/controllers/calificaciones_controller.dart';
import '../features/calificaciones/presentation/pages/calificaciones_page.dart';
import '../features/calificaciones_admin/domain/repositories/consulta_calificacion_repository.dart';
import '../features/calificaciones_admin/presentation/controllers/consulta_calificacion_controller.dart';
import '../features/calificaciones_admin/presentation/pages/consulta_calificacion_page.dart';
import '../features/dashboard/presentation/admin_dashboard_page.dart';
import '../features/dashboard/presentation/docente_dashboard_page.dart';
import '../features/estudiantes/domain/repositories/estudiante_repository.dart';
import '../features/estudiantes/presentation/controllers/estudiante_controller.dart';
import '../features/estudiantes/presentation/controllers/estudiantes_asignacion_controller.dart';
import '../features/estudiantes/presentation/pages/estudiantes_page.dart';
import '../features/estudiantes/presentation/pages/estudiantes_asignacion_page.dart';
import '../features/periodos/domain/repositories/periodo_academico_repository.dart';
import '../features/periodos/presentation/controllers/periodo_academico_controller.dart';
import '../features/periodos/presentation/pages/periodos_academicos_page.dart';
import '../features/inscripciones/domain/repositories/inscripcion_repository.dart';
import '../features/inscripciones/presentation/controllers/inscripcion_controller.dart';
import '../features/inscripciones/presentation/pages/inscripciones_page.dart';
import '../features/docentes/domain/repositories/docente_repository.dart';
import '../features/docentes/presentation/controllers/docente_controller.dart';
import '../features/docentes/presentation/pages/docentes_page.dart';
import '../features/usuarios/domain/repositories/usuario_repository.dart';
import '../features/usuarios/presentation/controllers/usuario_controller.dart';
import '../features/usuarios/presentation/pages/usuarios_page.dart';
import '../features/reportes/domain/repositories/reporte_repository.dart';
import '../features/reportes/presentation/controllers/reportes_controller.dart';
import '../features/reportes/presentation/pages/reportes_page.dart';
import 'route_guard.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter({
    required this.auth,
    required this.asignaturas,
    required this.asignacionesDocente,
    required this.estudiantes,
    required this.asistencias,
    required this.consultaAsistencias,
    required this.calificaciones,
    required this.consultaCalificaciones,
    required this.periodos,
    required this.inscripciones,
    required this.docentes,
    required this.usuarios,
    required this.reportes,
  });

  final AuthController auth;
  final AsignaturaRepository asignaturas;
  final AsignacionDocenteRepository asignacionesDocente;
  final EstudianteRepository estudiantes;
  final AsistenciaRepository asistencias;
  final ConsultaAsistenciaRepository consultaAsistencias;
  final CalificacionRepository calificaciones;
  final ConsultaCalificacionRepository consultaCalificaciones;
  final PeriodoAcademicoRepository periodos;
  final InscripcionRepository inscripciones;
  final DocenteRepository docentes;
  final UsuarioRepository usuarios;
  final ReporteRepository reportes;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final guard = RouteGuard(auth);
    final docenteDetail = _docenteDetailPage(settings, guard);
    if (docenteDetail != null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => docenteDetail,
      );
    }
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
      RouteNames.adminUsuarios => guard.isAdmin
          ? ChangeNotifierProvider(
              create: (_) => UsuarioController(
                usuarios,
                currentUserId: auth.profile!.id,
              ),
              child: const UsuariosPage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.adminAsignaturas => guard.isAdmin
          ? ChangeNotifierProvider(
              create: (_) => AsignaturaController(asignaturas),
              child: const AsignaturasPage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.adminEstudiantes => guard.isAdmin
          ? ChangeNotifierProvider(
              create: (_) => EstudianteController(estudiantes),
              child: const EstudiantesPage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.adminDocentes => guard.isAdmin
          ? ChangeNotifierProvider(
              create: (_) => DocenteController(docentes),
              child: const DocentesPage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.adminAsignaciones => guard.isAdmin
          ? ChangeNotifierProvider(
              create: (_) => AsignacionDocenteController(asignacionesDocente),
              child: const AsignacionesDocentePage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.adminPeriodos => guard.isAdmin
          ? ChangeNotifierProvider(
              create: (_) => PeriodoAcademicoController(periodos),
              child: const PeriodosAcademicosPage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.adminInscripciones => guard.isAdmin
          ? ChangeNotifierProvider(
              create: (_) => InscripcionController(inscripciones),
              child: const InscripcionesPage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.adminAsistencias => guard.isAdmin
          ? ChangeNotifierProvider(
              create: (_) => ConsultaAsistenciaController(consultaAsistencias),
              child: const ConsultaAsistenciaPage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.adminCalificaciones => guard.isAdmin
          ? ChangeNotifierProvider(
              create: (_) =>
                  ConsultaCalificacionController(consultaCalificaciones),
              child: const ConsultaCalificacionPage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.adminReportes => guard.isAdmin
          ? ChangeNotifierProvider(
              create: (_) => ReportesController(reportes),
              child: const ReportesPage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.docente => guard.isDocente
          ? const DocenteDashboardPage()
          : _UnauthorizedPage(authenticated: guard.hasSession),
      RouteNames.docenteAsignaturas => guard.isDocente
          ? ChangeNotifierProvider(
              create: (_) => MisAsignaturasController(asignacionesDocente),
              child: const MisAsignaturasPage(),
            )
          : _UnauthorizedPage(authenticated: guard.hasSession),
      _ => const _NotFoundPage(),
    };

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => page,
    );
  }

  Widget? _docenteDetailPage(RouteSettings settings, RouteGuard guard) {
    final uri = Uri.tryParse(settings.name ?? '');
    if (uri == null || uri.pathSegments.length != 4) return null;
    if (uri.pathSegments[0] != 'docente' ||
        uri.pathSegments[1] != 'asignaturas') {
      return null;
    }

    final asignacionId = int.tryParse(uri.pathSegments[2]);
    if (asignacionId == null) return const _NotFoundPage();
    if (!guard.isDocente) {
      return _UnauthorizedPage(authenticated: guard.hasSession);
    }

    final argument = settings.arguments;
    if (argument is! AsignacionDocente || argument.id != asignacionId) {
      return const _NotFoundPage();
    }

    return switch (uri.pathSegments[3]) {
      'estudiantes' => ChangeNotifierProvider(
          create: (_) =>
              EstudiantesAsignacionController(estudiantes, asignacionId),
          child: EstudiantesAsignacionPage(asignacion: argument),
        ),
      'asistencia' => ChangeNotifierProvider(
          create: (_) => AsistenciaController(
            asistencias,
            estudiantes,
            asignacionId,
          ),
          child: AsistenciaPage(asignacion: argument),
        ),
      'calificaciones' => ChangeNotifierProvider(
          create: (_) => CalificacionesController(
            calificaciones,
            estudiantes,
            asignacionId,
          ),
          child: CalificacionesPage(asignacion: argument),
        ),
      _ => null,
    };
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
