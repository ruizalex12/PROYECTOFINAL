class RouteNames {
  const RouteNames._();

  static const root = '/';
  static const login = '/login';
  static const admin = '/admin';
  static const adminUsuarios = '/admin/usuarios';
  static const adminEstudiantes = '/admin/estudiantes';
  static const adminDocentes = '/admin/docentes';
  static const adminAsignaturas = '/admin/asignaturas';
  static const adminAsignaciones = '/admin/asignaciones';
  static const adminPeriodos = '/admin/periodos';
  static const adminInscripciones = '/admin/inscripciones';
  static const adminAsistencias = '/admin/asistencias';
  static const adminCalificaciones = '/admin/calificaciones';
  static const adminReportes = '/admin/reportes';
  static const docente = '/docente';
  static const docenteAsignaturas = '/docente/asignaturas';

  static String docenteEstudiantes(int asignacionId) =>
      '/docente/asignaturas/$asignacionId/estudiantes';

  static String docenteAsistencia(int asignacionId) =>
      '/docente/asignaturas/$asignacionId/asistencia';

  static String docenteCalificaciones(int asignacionId) =>
      '/docente/asignaturas/$asignacionId/calificaciones';
}
