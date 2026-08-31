import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/academic_entities.dart';
import 'demo_academic_store.dart';

class EnrollmentService {
  EnrollmentService({required this.useSupabase});
  final bool useSupabase;
  SupabaseClient get db => Supabase.instance.client;
  Future<List<Profile>> profiles() async {
    if (!useSupabase) {
      return DemoAcademicStore.instance.profiles.values.toList();
    }
    final r = await db.from('perfiles').select().order('created_at');
    return r.map<Profile>((e) => Profile.fromMap(e)).toList();
  }

  Future<void> linkProfile(
      {required String profileId,
      required UserRole role,
      String? studentId,
      String? teacherId}) async {
    if (!useSupabase) return;
    await db.from('perfiles').update({
      'rol': role.name,
      'estudiante_id': role == UserRole.estudiante ? studentId : null,
      'docente_id': role == UserRole.docente ? teacherId : null
    }).eq('id', profileId);
  }

  Future<List<Student>> students() async {
    if (!useSupabase) return DemoAcademicStore.instance.students;
    final r = await db
        .from('estudiantes')
        .select()
        .eq('estado', 'Activo')
        .order('apellidos');
    return r.map<Student>((e) => Student.fromMap(e)).toList();
  }

  Future<List<Teacher>> teachers() async {
    if (!useSupabase) return DemoAcademicStore.instance.teachers;
    final r = await db
        .from('docentes')
        .select()
        .eq('estado', 'Activo')
        .order('apellidos');
    return r.map<Teacher>((e) => Teacher.fromMap(e)).toList();
  }

  Future<List<Course>> courses() async {
    if (!useSupabase) return DemoAcademicStore.instance.courses;
    final r = await db.from('cursos').select().order('nombre');
    return r.map<Course>((e) => Course.fromMap(e)).toList();
  }

  Future<List<Subject>> subjects() async {
    if (!useSupabase) return DemoAcademicStore.instance.subjects;
    final r = await db.from('materias').select().order('nombre');
    return r.map<Subject>((e) => Subject.fromMap(e)).toList();
  }

  Future<List<AcademicPeriod>> activePeriods() async {
    if (!useSupabase) {
      return DemoAcademicStore.instance.periods
          .where((p) => p.isActive)
          .toList();
    }
    final r = await db
        .from('periodos')
        .select()
        .eq('estado', 'Activo')
        .order('fecha_inicio', ascending: false);
    return r.map<AcademicPeriod>((e) => AcademicPeriod.fromMap(e)).toList();
  }

  Future<void> enroll(
      {required String studentId,
      required String courseId,
      required String periodId}) async {
    if (!useSupabase) {
      final s = DemoAcademicStore.instance;
      if (!s.students.any((e) => e.id == studentId) ||
          !s.courses.any((e) => e.id == courseId) ||
          !s.periods.any((e) => e.id == periodId && e.isActive)) {
        throw StateError('Los datos seleccionados no son válidos.');
      }
      if (s.enrollments.any((e) =>
          e.studentId == studentId &&
          e.courseId == courseId &&
          e.periodId == periodId)) {
        throw StateError('El estudiante ya está matriculado en este curso.');
      }
      s.enrollments.add(Enrollment(
          id: 'en${DateTime.now().microsecondsSinceEpoch}',
          studentId: studentId,
          courseId: courseId,
          periodId: periodId,
          status: 'Inscrito'));
      return;
    }
    await db.rpc('matricular_estudiante', params: {
      'p_estudiante_id': studentId,
      'p_curso_id': courseId,
      'p_periodo_id': periodId
    });
  }

  Future<void> assign(
      {required String teacherId,
      required String subjectId,
      required String courseId,
      required String periodId,
      String room = '',
      String schedule = ''}) async {
    if (!useSupabase) {
      final s = DemoAcademicStore.instance;
      if (s.assignments.any((a) =>
          a.subjectId == subjectId &&
          a.courseId == courseId &&
          a.periodId == periodId)) {
        throw StateError('Este curso y materia ya tienen una asignación.');
      }
      final t = s.teachers.firstWhere((x) => x.id == teacherId),
          c = s.courses.firstWhere((x) => x.id == courseId),
          m = s.subjects.firstWhere((x) => x.id == subjectId),
          p = s.periods.firstWhere((x) => x.id == periodId);
      s.assignments.add(CourseAssignment(
          id: 'a${DateTime.now().microsecondsSinceEpoch}',
          courseId: courseId,
          teacherId: teacherId,
          subjectId: subjectId,
          periodId: periodId,
          courseName: c.name,
          subjectName: m.name,
          teacherName: t.fullName,
          periodName: p.name,
          room: room,
          schedule: schedule));
      return;
    }
    await db.from('asignaciones').insert({
      'docente_id': teacherId,
      'materia_id': subjectId,
      'curso_id': courseId,
      'periodo_id': periodId,
      'aula': room,
      'horario': schedule
    });
  }
}
