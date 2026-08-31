import '../models/academic_entities.dart';

class DemoAcademicStore {
  DemoAcademicStore._();
  static final instance = DemoAcademicStore._();
  String activeRole = 'admin';
  final tasks = <Map<String, dynamic>>[
    {
      'id': 'task1',
      'asignacion_id': 'a1',
      'titulo': 'Diseño de topología LAN',
      'descripcion': 'Elabora una propuesta de red para el laboratorio.',
      'fecha_limite': '2026-09-15T23:59:00',
      'puntaje_maximo': 100,
      'estado': 'Publicada'
    }
  ];
  final submissions = <Map<String, dynamic>>[];
  final attendanceSessions = <Map<String, dynamic>>[
    {
      'id': 'session1',
      'asignacion_id': 'a1',
      'titulo': 'Clase práctica de redes',
      'fecha': '2026-08-31',
      'abre_en': '2026-08-31T00:00:00',
      'cierra_en': '2026-12-31T23:59:00',
      'activa': true
    }
  ];
  final profiles = <String, Profile>{
    'admin': const Profile(
        id: 'demo-admin',
        names: 'Ana',
        lastNames: 'Administradora',
        email: 'admin@demo.edu',
        role: UserRole.admin),
    'docente': const Profile(
        id: 'demo-teacher-user',
        names: 'Carlos',
        lastNames: 'López',
        email: 'docente@demo.edu',
        role: UserRole.docente,
        teacherId: 'd1'),
    'estudiante': const Profile(
        id: 'demo-student-user',
        names: 'Juan',
        lastNames: 'Pérez',
        email: 'estudiante@demo.edu',
        role: UserRole.estudiante,
        studentId: 'e1'),
  };
  final students = <Student>[
    const Student(
        id: 'e1',
        code: 'EST-001',
        names: 'Juan',
        lastNames: 'Pérez',
        email: 'estudiante@demo.edu'),
    const Student(
        id: 'e2',
        code: 'EST-002',
        names: 'María',
        lastNames: 'Flores',
        email: 'maria@demo.edu')
  ];
  final teachers = <Teacher>[
    const Teacher(
        id: 'd1',
        code: 'DOC-001',
        names: 'Carlos',
        lastNames: 'López',
        email: 'docente@demo.edu'),
    const Teacher(
        id: 'd2',
        code: 'DOC-002',
        names: 'María',
        lastNames: 'Mendoza',
        email: 'maria@demo.edu'),
    const Teacher(
        id: 'd3',
        code: 'DOC-003',
        names: 'Luis',
        lastNames: 'Vargas',
        email: 'luis@demo.edu')
  ];
  final subjects = <Subject>[
    const Subject(id: 'm1', code: 'INF-301', name: 'Redes III'),
    const Subject(id: 'm2', code: 'INF-302', name: 'Base de Datos II'),
    const Subject(id: 'm3', code: 'INF-303', name: 'Ingeniería de Software'),
    const Subject(id: 'm4', code: 'INF-304', name: 'Sistemas Operativos'),
    const Subject(id: 'm5', code: 'MAT-305', name: 'Estadística Aplicada')
  ];
  final periods = <AcademicPeriod>[
    const AcademicPeriod(id: 'p1', name: '2026-I', status: 'Activo')
  ];
  final courses = <Course>[
    const Course(
        id: 'c1', name: 'Redes III', parallel: 'A', management: '2026'),
    const Course(
        id: 'c2', name: 'Base de Datos II', parallel: 'A', management: '2026'),
    const Course(
        id: 'c3',
        name: 'Ingeniería de Software',
        parallel: 'A',
        management: '2026'),
    const Course(
        id: 'c4',
        name: 'Sistemas Operativos',
        parallel: 'A',
        management: '2026'),
    const Course(
        id: 'c5',
        name: 'Estadística Aplicada',
        parallel: 'A',
        management: '2026')
  ];
  final assignments = <CourseAssignment>[
    const CourseAssignment(
        id: 'a1',
        courseId: 'c1',
        teacherId: 'd1',
        subjectId: 'm1',
        periodId: 'p1',
        courseName: 'Redes III',
        subjectName: 'Redes III',
        teacherName: 'Carlos López',
        periodName: '2026-I',
        room: 'Lab. 2',
        schedule: 'Lun y Mié 10:00',
        studentCount: 2),
    const CourseAssignment(
        id: 'a2',
        courseId: 'c2',
        teacherId: 'd2',
        subjectId: 'm2',
        periodId: 'p1',
        courseName: 'Base de Datos II',
        subjectName: 'Base de Datos II',
        teacherName: 'María Mendoza',
        periodName: '2026-I',
        room: 'Lab. 3',
        schedule: 'Mar 10:00 - 12:00',
        studentCount: 2),
    const CourseAssignment(
        id: 'a3',
        courseId: 'c3',
        teacherId: 'd3',
        subjectId: 'm3',
        periodId: 'p1',
        courseName: 'Ingeniería de Software',
        subjectName: 'Ingeniería de Software',
        teacherName: 'Luis Vargas',
        periodName: '2026-I',
        room: 'Aula 12',
        schedule: 'Mié 14:00 - 16:00',
        studentCount: 2),
    const CourseAssignment(
        id: 'a4',
        courseId: 'c4',
        teacherId: 'd1',
        subjectId: 'm4',
        periodId: 'p1',
        courseName: 'Sistemas Operativos',
        subjectName: 'Sistemas Operativos',
        teacherName: 'Carlos López',
        periodName: '2026-I',
        room: 'Lab. 2',
        schedule: 'Jue 08:00 - 10:00',
        studentCount: 2),
    const CourseAssignment(
        id: 'a5',
        courseId: 'c5',
        teacherId: 'd2',
        subjectId: 'm5',
        periodId: 'p1',
        courseName: 'Estadística Aplicada',
        subjectName: 'Estadística Aplicada',
        teacherName: 'María Mendoza',
        periodName: '2026-I',
        room: 'Aula 8',
        schedule: 'Vie 10:00 - 12:00',
        studentCount: 2)
  ];
  final enrollments = <Enrollment>[
    const Enrollment(
        id: 'en1',
        studentId: 'e1',
        courseId: 'c1',
        periodId: 'p1',
        status: 'Inscrito'),
    const Enrollment(
        id: 'en2',
        studentId: 'e2',
        courseId: 'c1',
        periodId: 'p1',
        status: 'Inscrito'),
    const Enrollment(
        id: 'en3',
        studentId: 'e1',
        courseId: 'c2',
        periodId: 'p1',
        status: 'Inscrito'),
    const Enrollment(
        id: 'en4',
        studentId: 'e1',
        courseId: 'c3',
        periodId: 'p1',
        status: 'Inscrito'),
    const Enrollment(
        id: 'en5',
        studentId: 'e1',
        courseId: 'c4',
        periodId: 'p1',
        status: 'Inscrito'),
    const Enrollment(
        id: 'en6',
        studentId: 'e1',
        courseId: 'c5',
        periodId: 'p1',
        status: 'Inscrito')
  ];
  final evaluations = <Evaluation>[
    const Evaluation(
        id: 'ev1',
        assignmentId: 'a1',
        title: 'Primer parcial',
        type: 'Parcial',
        weight: 30,
        date: '2026-09-10'),
    const Evaluation(
        id: 'ev2',
        assignmentId: 'a1',
        title: 'Trabajo práctico',
        type: 'Práctico',
        weight: 20,
        date: '2026-09-20')
  ];
  final grades = <Grade>[
    const Grade(id: 'g1', evaluationId: 'ev1', studentId: 'e1', score: 82),
    const Grade(id: 'g2', evaluationId: 'ev2', studentId: 'e1', score: 90)
  ];
  final attendance = <Attendance>[
    const Attendance(
        id: 'at1',
        assignmentId: 'a1',
        studentId: 'e1',
        date: '2026-08-10',
        status: 'Presente'),
    const Attendance(
        id: 'at2',
        assignmentId: 'a1',
        studentId: 'e1',
        date: '2026-08-12',
        status: 'Justificado')
  ];
  final announcements = <Announcement>[
    const Announcement(
        id: 'an1',
        title: 'Laboratorio de redes',
        content: 'Traer cable UTP para la siguiente clase.',
        publishedAt: '2026-08-20')
  ];
}
