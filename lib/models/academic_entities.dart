enum UserRole { admin, docente, estudiante }

UserRole roleFromString(String? value) {
  if (value == 'docente') return UserRole.docente;
  if (value == 'estudiante') return UserRole.estudiante;
  return UserRole.admin;
}

class Profile {
  const Profile(
      {required this.id,
      required this.names,
      required this.lastNames,
      required this.email,
      required this.role,
      this.studentId,
      this.teacherId});
  final String id, names, lastNames, email;
  final UserRole role;
  final String? studentId, teacherId;
  String get fullName => ('$names $lastNames').trim();
  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
      id: m['id'].toString(),
      names: (m['nombres'] ?? '').toString(),
      lastNames: (m['apellidos'] ?? '').toString(),
      email: (m['email'] ?? '').toString(),
      role: roleFromString(m['rol']?.toString()),
      studentId: m['estudiante_id']?.toString(),
      teacherId: m['docente_id']?.toString());
}

class Student {
  const Student(
      {required this.id,
      required this.code,
      required this.names,
      required this.lastNames,
      required this.email});
  final String id, code, names, lastNames, email;
  String get fullName => '$names $lastNames';
  factory Student.fromMap(Map<String, dynamic> m) => Student(
      id: m['id'].toString(),
      code: (m['codigo'] ?? '').toString(),
      names: (m['nombres'] ?? '').toString(),
      lastNames: (m['apellidos'] ?? '').toString(),
      email: (m['email'] ?? '').toString());
}

class Teacher {
  const Teacher(
      {required this.id,
      required this.code,
      required this.names,
      required this.lastNames,
      required this.email});
  final String id, code, names, lastNames, email;
  String get fullName => '$names $lastNames';
  factory Teacher.fromMap(Map<String, dynamic> m) => Teacher(
      id: m['id'].toString(),
      code: (m['codigo'] ?? '').toString(),
      names: (m['nombres'] ?? '').toString(),
      lastNames: (m['apellidos'] ?? '').toString(),
      email: (m['email'] ?? '').toString());
}

class Subject {
  const Subject({required this.id, required this.code, required this.name});
  final String id, code, name;
  factory Subject.fromMap(Map<String, dynamic> m) => Subject(
      id: m['id'].toString(),
      code: (m['codigo'] ?? '').toString(),
      name: (m['nombre'] ?? '').toString());
}

class AcademicPeriod {
  const AcademicPeriod(
      {required this.id, required this.name, required this.status});
  final String id, name, status;
  bool get isActive => status.toLowerCase() == 'activo';
  factory AcademicPeriod.fromMap(Map<String, dynamic> m) => AcademicPeriod(
      id: m['id'].toString(),
      name: (m['nombre'] ?? '').toString(),
      status: (m['estado'] ?? '').toString());
}

class Course {
  const Course(
      {required this.id,
      required this.name,
      required this.parallel,
      required this.management});
  final String id, name, parallel, management;
  factory Course.fromMap(Map<String, dynamic> m) => Course(
      id: m['id'].toString(),
      name: (m['nombre'] ?? '').toString(),
      parallel: (m['paralelo'] ?? '').toString(),
      management: (m['gestion'] ?? '').toString());
}

class CourseAssignment {
  const CourseAssignment(
      {required this.id,
      required this.courseId,
      required this.teacherId,
      required this.subjectId,
      required this.periodId,
      required this.courseName,
      required this.subjectName,
      required this.teacherName,
      required this.periodName,
      this.room = '',
      this.schedule = '',
      this.studentCount = 0});
  final String id,
      courseId,
      teacherId,
      subjectId,
      periodId,
      courseName,
      subjectName,
      teacherName,
      periodName,
      room,
      schedule;
  final int studentCount;
  factory CourseAssignment.fromMap(Map<String, dynamic> m) {
    final c = Map<String, dynamic>.from(m['cursos'] ?? {}),
        s = Map<String, dynamic>.from(m['materias'] ?? {}),
        t = Map<String, dynamic>.from(m['docentes'] ?? {}),
        p = Map<String, dynamic>.from(m['periodos'] ?? {});
    return CourseAssignment(
        id: m['id'].toString(),
        courseId: m['curso_id'].toString(),
        teacherId: m['docente_id'].toString(),
        subjectId: m['materia_id'].toString(),
        periodId: m['periodo_id'].toString(),
        courseName: (c['nombre'] ?? '').toString(),
        subjectName: (s['nombre'] ?? '').toString(),
        teacherName: '${t['nombres'] ?? ''} ${t['apellidos'] ?? ''}'.trim(),
        periodName: (p['nombre'] ?? '').toString(),
        room: (m['aula'] ?? '').toString(),
        schedule: (m['horario'] ?? '').toString(),
        studentCount: (m['student_count'] as num?)?.toInt() ?? 0);
  }
}

class Enrollment {
  const Enrollment(
      {required this.id,
      required this.studentId,
      required this.courseId,
      required this.periodId,
      required this.status});
  final String id, studentId, courseId, periodId, status;
  factory Enrollment.fromMap(Map<String, dynamic> m) => Enrollment(
      id: m['id'].toString(),
      studentId: m['estudiante_id'].toString(),
      courseId: m['curso_id'].toString(),
      periodId: m['periodo_id'].toString(),
      status: (m['estado'] ?? '').toString());
}

class Attendance {
  const Attendance(
      {required this.id,
      required this.assignmentId,
      required this.studentId,
      required this.date,
      required this.status});
  final String id, assignmentId, studentId, date, status;
  factory Attendance.fromMap(Map<String, dynamic> m) => Attendance(
      id: m['id'].toString(),
      assignmentId: m['asignacion_id'].toString(),
      studentId: m['estudiante_id'].toString(),
      date: m['fecha'].toString(),
      status: m['estado'].toString());
}

class Evaluation {
  const Evaluation(
      {required this.id,
      required this.assignmentId,
      required this.title,
      required this.type,
      required this.weight,
      required this.date});
  final String id, assignmentId, title, type, date;
  final double weight;
  factory Evaluation.fromMap(Map<String, dynamic> m) => Evaluation(
      id: m['id'].toString(),
      assignmentId: m['asignacion_id'].toString(),
      title: m['titulo'].toString(),
      type: m['tipo'].toString(),
      weight: (m['ponderacion'] as num).toDouble(),
      date: m['fecha'].toString());
}

class Grade {
  const Grade(
      {required this.id,
      required this.evaluationId,
      required this.studentId,
      required this.score});
  final String id, evaluationId, studentId;
  final double score;
  factory Grade.fromMap(Map<String, dynamic> m) => Grade(
      id: m['id'].toString(),
      evaluationId: m['evaluacion_id'].toString(),
      studentId: m['estudiante_id'].toString(),
      score: (m['nota'] as num).toDouble());
}

class Announcement {
  const Announcement(
      {required this.id,
      required this.title,
      required this.content,
      required this.publishedAt});
  final String id, title, content, publishedAt;
  factory Announcement.fromMap(Map<String, dynamic> m) => Announcement(
      id: m['id'].toString(),
      title: m['titulo'].toString(),
      content: m['contenido'].toString(),
      publishedAt: (m['publicado_en'] ?? '').toString());
}

class StudentCourseData {
  const StudentCourseData(
      {required this.assignment,
      required this.grades,
      required this.attendance,
      required this.announcements});
  final CourseAssignment assignment;
  final List<Map<String, dynamic>> grades, attendance;
  final List<Announcement> announcements;
  double get average => grades.isEmpty
      ? 0
      : grades
              .map((e) => (e['nota'] as num).toDouble())
              .reduce((a, b) => a + b) /
          grades.length;
  double get attendancePercent => attendance.isEmpty
      ? 0
      : attendance
              .where((e) =>
                  e['estado'] == 'Presente' ||
                  e['estado'] == 'Justificado' ||
                  e['estado'] == 'Licencia')
              .length *
          100 /
          attendance.length;
}
