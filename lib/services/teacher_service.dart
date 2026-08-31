import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/academic_entities.dart';
import 'demo_academic_store.dart';

class TeacherService {
  TeacherService({required this.useSupabase});
  final bool useSupabase;
  SupabaseClient get db => Supabase.instance.client;
  Future<List<Map<String, dynamic>>> tasks(String assignmentId) async {
    if (!useSupabase)
      return DemoAcademicStore.instance.tasks
          .where((x) => x['asignacion_id'] == assignmentId)
          .toList();
    return List<Map<String, dynamic>>.from(await db
        .from('tareas')
        .select()
        .eq('asignacion_id', assignmentId)
        .order('fecha_limite'));
  }

  Future<void> saveTask(
      {String? id,
      required String assignmentId,
      required String title,
      required String description,
      required String deadline,
      double maxScore = 100}) async {
    if (title.trim().length < 3)
      throw ArgumentError('El título debe tener al menos 3 caracteres.');
    if (DateTime.tryParse(deadline) == null)
      throw ArgumentError('La fecha límite no es válida.');
    final values = {
      'asignacion_id': assignmentId,
      'titulo': title.trim(),
      'descripcion': description.trim(),
      'fecha_limite': deadline,
      'puntaje_maximo': maxScore,
      'estado': 'Publicada'
    };
    if (!useSupabase) {
      final list = DemoAcademicStore.instance.tasks;
      if (id == null) {
        list.add(
            {...values, 'id': 'task${DateTime.now().microsecondsSinceEpoch}'});
      } else {
        final i = list.indexWhere((x) => x['id'] == id);
        if (i >= 0) list[i] = {...list[i], ...values};
      }
      return;
    }
    if (id == null) {
      await db.from('tareas').insert(values);
    } else {
      await db.from('tareas').update(values).eq('id', id);
    }
  }

  Future<void> deleteTask(String id) async {
    if (!useSupabase) {
      DemoAcademicStore.instance.tasks.removeWhere((x) => x['id'] == id);
      return;
    }
    await db.from('tareas').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> submissions(String taskId) async {
    if (!useSupabase)
      return DemoAcademicStore.instance.submissions
          .where((x) => x['tarea_id'] == taskId)
          .toList();
    return List<Map<String, dynamic>>.from(await db
        .from('entregas_tarea')
        .select('*,estudiantes(nombres,apellidos,codigo)')
        .eq('tarea_id', taskId)
        .order('entregado_en'));
  }

  Future<void> gradeSubmission(
      String id, double score, String feedback, double maxScore) async {
    if (score < 0 || score > maxScore)
      throw ArgumentError('La nota debe estar entre 0 y $maxScore.');
    if (!useSupabase) {
      final x = DemoAcademicStore.instance.submissions
          .firstWhere((e) => e['id'] == id);
      x['nota'] = score;
      x['retroalimentacion'] = feedback;
      return;
    }
    await db.from('entregas_tarea').update(
        {'nota': score, 'retroalimentacion': feedback.trim()}).eq('id', id);
  }

  Future<void> openAttendance(
      String assignmentId, String title, int minutes) async {
    if (minutes < 5 || minutes > 180)
      throw ArgumentError('La duración debe estar entre 5 y 180 minutos.');
    final now = DateTime.now(), end = now.add(Duration(minutes: minutes));
    final row = {
      'id': 'session${now.microsecondsSinceEpoch}',
      'asignacion_id': assignmentId,
      'titulo': title.trim().isEmpty ? 'Clase' : title.trim(),
      'fecha': now.toIso8601String().substring(0, 10),
      'abre_en': now.toIso8601String(),
      'cierra_en': end.toIso8601String(),
      'activa': true
    };
    if (!useSupabase) {
      DemoAcademicStore.instance.attendanceSessions.add(row);
      return;
    }
    row.remove('id');
    await db.from('sesiones_asistencia').insert(row);
  }

  Future<List<CourseAssignment>> myCourses(String teacherId) async {
    if (!useSupabase)
      return DemoAcademicStore.instance.assignments
          .where((a) => a.teacherId == teacherId)
          .toList();
    final rows = await db
        .from('asignaciones')
        .select('*,cursos(*),materias(*),docentes(*),periodos(*)')
        .eq('docente_id', teacherId);
    final result = <CourseAssignment>[];
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw);
      final count = await db
          .from('matriculas')
          .count(CountOption.exact)
          .eq('curso_id', row['curso_id'])
          .eq('periodo_id', row['periodo_id']);
      result.add(CourseAssignment.fromMap({...row, 'student_count': count}));
    }
    return result;
  }

  Future<List<Student>> courseStudents(CourseAssignment a) async {
    if (!useSupabase) {
      final ids = DemoAcademicStore.instance.enrollments
          .where((e) => e.courseId == a.courseId && e.periodId == a.periodId)
          .map((e) => e.studentId);
      return DemoAcademicStore.instance.students
          .where((s) => ids.contains(s.id))
          .toList();
    }
    final rows = await db
        .from('matriculas')
        .select('estudiantes(*)')
        .eq('curso_id', a.courseId)
        .eq('periodo_id', a.periodId)
        .eq('estado', 'Inscrito');
    return rows
        .map<Student>(
            (r) => Student.fromMap(Map<String, dynamic>.from(r['estudiantes'])))
        .toList();
  }

  Future<List<Evaluation>> evaluations(String assignmentId) async {
    if (!useSupabase)
      return DemoAcademicStore.instance.evaluations
          .where((e) => e.assignmentId == assignmentId)
          .toList();
    final rows = await db
        .from('evaluaciones')
        .select()
        .eq('asignacion_id', assignmentId)
        .order('fecha');
    return rows.map<Evaluation>((r) => Evaluation.fromMap(r)).toList();
  }

  Future<void> createEvaluation(String assignmentId, String title,
      String description, String date, double weight) async {
    if (weight <= 0 || weight > 100)
      throw ArgumentError('El porcentaje debe estar entre 1 y 100.');
    if (!useSupabase) {
      DemoAcademicStore.instance.evaluations.add(Evaluation(
          id: 'ev${DateTime.now().microsecondsSinceEpoch}',
          assignmentId: assignmentId,
          title: title,
          type: description.isEmpty ? 'Evaluación' : description,
          weight: weight,
          date: date));
      return;
    }
    await db.from('evaluaciones').insert({
      'asignacion_id': assignmentId,
      'titulo': title,
      'tipo': description.isEmpty ? 'Evaluación' : description,
      'ponderacion': weight,
      'fecha': date
    });
  }

  Future<void> saveAttendance(
      String assignmentId, String studentId, String date, String status) async {
    if (!useSupabase) {
      final list = DemoAcademicStore.instance.attendance;
      list.removeWhere((e) =>
          e.assignmentId == assignmentId &&
          e.studentId == studentId &&
          e.date == date);
      list.add(Attendance(
          id: 'at${DateTime.now().microsecondsSinceEpoch}',
          assignmentId: assignmentId,
          studentId: studentId,
          date: date,
          status: status));
      return;
    }
    await db.from('asistencias').upsert({
      'asignacion_id': assignmentId,
      'estudiante_id': studentId,
      'fecha': date,
      'estado': status
    }, onConflict: 'asignacion_id,estudiante_id,fecha');
  }

  Future<void> saveGrade(
      String evaluationId, String studentId, double score) async {
    if (score < 0 || score > 100)
      throw ArgumentError('La nota debe estar entre 0 y 100.');
    if (!useSupabase) {
      final list = DemoAcademicStore.instance.grades;
      list.removeWhere(
          (g) => g.evaluationId == evaluationId && g.studentId == studentId);
      list.add(Grade(
          id: 'g${DateTime.now().microsecondsSinceEpoch}',
          evaluationId: evaluationId,
          studentId: studentId,
          score: score));
      return;
    }
    await db.from('calificaciones').upsert({
      'evaluacion_id': evaluationId,
      'estudiante_id': studentId,
      'nota': score
    }, onConflict: 'evaluacion_id,estudiante_id');
  }

  Future<void> publish(
      String assignmentId, String title, String content) async {
    if (!useSupabase) {
      DemoAcademicStore.instance.announcements.insert(
          0,
          Announcement(
              id: 'an${DateTime.now().microsecondsSinceEpoch}',
              title: title,
              content: content,
              publishedAt: DateTime.now().toIso8601String()));
      return;
    }
    await db.from('anuncios').insert({
      'asignacion_id': assignmentId,
      'titulo': title,
      'contenido': content,
      'publicado_por': db.auth.currentUser!.id
    });
  }
}
