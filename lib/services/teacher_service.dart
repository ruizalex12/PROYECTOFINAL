import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/academic_entities.dart';
import 'demo_academic_store.dart';

class TeacherService {
  TeacherService({required this.useSupabase});
  final bool useSupabase;
  SupabaseClient get db => Supabase.instance.client;
  Future<List<Map<String, dynamic>>> tasks(String assignmentId) async {
    if (!useSupabase) {
      return DemoAcademicStore.instance.tasks
          .where((x) => x['asignacion_id'] == assignmentId)
          .toList();
    }
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
    if (title.trim().length < 3) {
      throw ArgumentError('El título debe tener al menos 3 caracteres.');
    }
    if (DateTime.tryParse(deadline) == null) {
      throw ArgumentError('La fecha límite no es válida.');
    }
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
    if (!useSupabase) {
      return DemoAcademicStore.instance.submissions
          .where((x) => x['tarea_id'] == taskId)
          .toList();
    }
    return List<Map<String, dynamic>>.from(await db
        .from('entregas_tarea')
        .select('*,estudiantes(nombres,apellidos,codigo)')
        .eq('tarea_id', taskId)
        .order('entregado_en'));
  }

  Future<Uint8List> downloadSubmissionFile(Map<String, dynamic> submission) {
    if (!useSupabase) {
      throw StateError('La descarga requiere conexión con Supabase.');
    }
    final path = submission['archivo_ruta']?.toString() ?? '';
    if (path.isEmpty) throw StateError('La entrega no tiene archivo adjunto.');
    return db.storage.from('documentos-estudiantes').download(path);
  }

  Future<void> gradeSubmission(
      String id, double score, String feedback, double maxScore) async {
    if (score < 0 || score > maxScore) {
      throw ArgumentError('La nota debe estar entre 0 y $maxScore.');
    }
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
    if (minutes < 5 || minutes > 180) {
      throw ArgumentError('La duración debe estar entre 5 y 180 minutos.');
    }
    final utcNow = DateTime.now().toUtc(),
        boliviaNow = utcNow.subtract(const Duration(hours: 4)),
        utcEnd = utcNow.add(Duration(minutes: minutes));
    final row = {
      'id': 'session${utcNow.microsecondsSinceEpoch}',
      'asignacion_id': assignmentId,
      'titulo': title.trim().isEmpty ? 'Clase' : title.trim(),
      'fecha': boliviaNow.toIso8601String().substring(0, 10),
      'abre_en': utcNow.toIso8601String(),
      'cierra_en': utcEnd.toIso8601String(),
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
    if (!useSupabase) {
      return DemoAcademicStore.instance.assignments
          .where((a) => a.teacherId == teacherId)
          .toList();
    }
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

  Future<Map<String, dynamic>> studentPerformance(
      CourseAssignment assignment, Student student) async {
    List<Evaluation> evaluationRows;
    List<Grade> gradeRows;
    List<Map<String, dynamic>> attendanceRows;
    List<Map<String, dynamic>> taskRows;
    List<Map<String, dynamic>> submissionRows;

    if (!useSupabase) {
      final store = DemoAcademicStore.instance;
      evaluationRows = store.evaluations
          .where((e) => e.assignmentId == assignment.id)
          .toList();
      final evaluationIds = evaluationRows.map((e) => e.id).toSet();
      gradeRows = store.grades
          .where((g) =>
              g.studentId == student.id &&
              evaluationIds.contains(g.evaluationId))
          .toList();
      attendanceRows = store.attendance
          .where((a) =>
              a.assignmentId == assignment.id && a.studentId == student.id)
          .map((a) => {'fecha': a.date, 'estado': a.status})
          .toList();
      taskRows = store.tasks
          .where((t) => t['asignacion_id'] == assignment.id)
          .toList();
      final taskIds = taskRows.map((t) => t['id'].toString()).toSet();
      submissionRows = store.submissions
          .where((s) =>
              s['estudiante_id'] == student.id &&
              taskIds.contains(s['tarea_id'].toString()))
          .toList();
    } else {
      evaluationRows = await evaluations(assignment.id);
      final evaluationIds = evaluationRows.map((e) => e.id).toList();
      if (evaluationIds.isEmpty) {
        gradeRows = [];
      } else {
        final rows = await db
            .from('calificaciones')
            .select()
            .eq('estudiante_id', student.id)
            .inFilter('evaluacion_id', evaluationIds);
        gradeRows = rows.map<Grade>((r) => Grade.fromMap(r)).toList();
      }
      final manualAttendance = await db
          .from('asistencias')
          .select('fecha,estado')
          .eq('asignacion_id', assignment.id)
          .eq('estudiante_id', student.id);
      final selfAttendance = await db
          .from('marcaciones_asistencia')
          .select('fecha,estado')
          .eq('asignacion_id', assignment.id)
          .eq('estudiante_id', student.id);
      attendanceRows = [
        ...List<Map<String, dynamic>>.from(manualAttendance),
        ...List<Map<String, dynamic>>.from(selfAttendance)
      ];
      taskRows = await tasks(assignment.id);
      final taskIds = taskRows.map((t) => t['id'].toString()).toList();
      if (taskIds.isEmpty) {
        submissionRows = [];
      } else {
        submissionRows = List<Map<String, dynamic>>.from(await db
            .from('entregas_tarea')
            .select('tarea_id,nota,entregado_en')
            .eq('estudiante_id', student.id)
            .inFilter('tarea_id', taskIds));
      }
    }

    var weightedPoints = 0.0, evaluatedWeight = 0.0;
    for (final grade in gradeRows) {
      final evaluation =
          evaluationRows.where((e) => e.id == grade.evaluationId).firstOrNull;
      if (evaluation != null) {
        weightedPoints += grade.score * evaluation.weight;
        evaluatedWeight += evaluation.weight;
      }
    }
    final attended = attendanceRows.where((a) {
      final status = a['estado']?.toString();
      return status == 'Presente' || status == 'Retraso';
    }).length;
    var taskScoreSum = 0.0, gradedTasks = 0;
    for (final submission in submissionRows) {
      final score = (submission['nota'] as num?)?.toDouble();
      final task = taskRows
          .where((t) => t['id'].toString() == submission['tarea_id'].toString())
          .firstOrNull;
      final maximum = (task?['puntaje_maximo'] as num?)?.toDouble();
      if (score != null && maximum != null && maximum > 0) {
        taskScoreSum += score * 100 / maximum;
        gradedTasks++;
      }
    }
    return {
      'average': evaluatedWeight == 0 ? 0.0 : weightedPoints / evaluatedWeight,
      'evaluations_total': evaluationRows.length,
      'evaluations_graded': gradeRows.length,
      'attendance_total': attendanceRows.length,
      'attendance_present': attended,
      'attendance_percent':
          attendanceRows.isEmpty ? 0.0 : attended * 100 / attendanceRows.length,
      'tasks_total': taskRows.length,
      'tasks_submitted': submissionRows.length,
      'tasks_graded': gradedTasks,
      'task_percent': taskRows.isEmpty
          ? 0.0
          : submissionRows.length * 100 / taskRows.length,
      'task_score': gradedTasks == 0 ? 0.0 : taskScoreSum / gradedTasks,
      'grades': gradeRows,
      'evaluations': evaluationRows,
      'attendance': attendanceRows,
      'submissions': submissionRows,
    };
  }

  Future<List<Evaluation>> evaluations(String assignmentId) async {
    if (!useSupabase) {
      return DemoAcademicStore.instance.evaluations
          .where((e) => e.assignmentId == assignmentId)
          .toList();
    }
    final rows = await db
        .from('evaluaciones')
        .select()
        .eq('asignacion_id', assignmentId)
        .order('fecha');
    return rows.map<Evaluation>((r) => Evaluation.fromMap(r)).toList();
  }

  Future<void> createEvaluation(String assignmentId, String title,
      String description, String date, double weight) async {
    if (weight <= 0 || weight > 100) {
      throw ArgumentError('El porcentaje debe estar entre 1 y 100.');
    }
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
    if (score < 0 || score > 100) {
      throw ArgumentError('La nota debe estar entre 0 y 100.');
    }
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
    if (title.trim().length < 3 || content.trim().length < 3) {
      throw ArgumentError(
          'El título y el contenido deben tener al menos 3 caracteres.');
    }
    if (!useSupabase) {
      DemoAcademicStore.instance.announcements.insert(
          0,
          Announcement(
              id: 'an${DateTime.now().microsecondsSinceEpoch}',
              title: title.trim(),
              content: content.trim(),
              publishedAt: DateTime.now().toIso8601String()));
      return;
    }
    await db.from('anuncios').insert({
      'asignacion_id': assignmentId,
      'titulo': title.trim(),
      'contenido': content.trim(),
      'publicado_por': db.auth.currentUser!.id
    });
  }

  Future<List<Announcement>> announcements(String assignmentId) async {
    if (!useSupabase) {
      return List<Announcement>.from(
          DemoAcademicStore.instance.announcements.reversed);
    }
    final rows = await db
        .from('anuncios')
        .select()
        .eq('asignacion_id', assignmentId)
        .eq('publicado_por', db.auth.currentUser!.id)
        .order('publicado_en', ascending: false);
    return rows.map<Announcement>((r) => Announcement.fromMap(r)).toList();
  }

  Future<void> deleteAnnouncement(String id) async {
    if (!useSupabase) {
      DemoAcademicStore.instance.announcements.removeWhere((a) => a.id == id);
      return;
    }
    await db.from('anuncios').delete().eq('id', id);
  }
}
