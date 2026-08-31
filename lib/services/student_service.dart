import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/academic_entities.dart';
import 'demo_academic_store.dart';

class StudentService {
  StudentService({required this.useSupabase});
  final bool useSupabase;
  SupabaseClient get db => Supabase.instance.client;
  static final List<Map<String, dynamic>> _demoDocuments = [];
  Future<List<Map<String, dynamic>>> tasks(
      String assignmentId, String studentId) async {
    if (!useSupabase) {
      return DemoAcademicStore.instance.tasks
          .where((x) =>
              x['asignacion_id'] == assignmentId && x['estado'] == 'Publicada')
          .map((x) => {
                ...x,
                'entregas_tarea': DemoAcademicStore.instance.submissions
                    .where((e) =>
                        e['tarea_id'] == x['id'] &&
                        e['estudiante_id'] == studentId)
                    .toList()
              })
          .toList();
    }
    return List<Map<String, dynamic>>.from(await db
        .from('tareas')
        .select('*,entregas_tarea(*)')
        .eq('asignacion_id', assignmentId)
        .eq('estado', 'Publicada')
        .order('fecha_limite'));
  }

  Future<void> submitTask(
      {required String taskId,
      required String studentId,
      required String comment}) async {
    if (comment.trim().isEmpty)
      throw ArgumentError('Escribe un comentario para la entrega.');
    final values = {
      'tarea_id': taskId,
      'estudiante_id': studentId,
      'comentario': comment.trim(),
      'entregado_en': DateTime.now().toIso8601String()
    };
    if (!useSupabase) {
      final list = DemoAcademicStore.instance.submissions;
      final i = list.indexWhere(
          (x) => x['tarea_id'] == taskId && x['estudiante_id'] == studentId);
      if (i >= 0) {
        list[i] = {...list[i], ...values};
      } else {
        list.add(
            {...values, 'id': 'sub${DateTime.now().microsecondsSinceEpoch}'});
      }
      return;
    }
    await db
        .from('entregas_tarea')
        .upsert(values, onConflict: 'tarea_id,estudiante_id');
  }

  Future<List<Map<String, dynamic>>> openAttendanceSessions(
      String studentId) async {
    if (!useSupabase) {
      final ids = (await myCourses(studentId)).map((x) => x.id);
      return DemoAcademicStore.instance.attendanceSessions
          .where((x) => ids.contains(x['asignacion_id']) && x['activa'] == true)
          .toList();
    }
    final courses = await myCourses(studentId),
        ids = courses.map((x) => x.id).toList();
    if (ids.isEmpty) return [];
    return List<Map<String, dynamic>>.from(await db
        .from('sesiones_asistencia')
        .select('*,asignaciones(materias(nombre),docentes(nombres,apellidos))')
        .inFilter('asignacion_id', ids)
        .eq('activa', true)
        .lte('abre_en', DateTime.now().toIso8601String())
        .gte('cierra_en', DateTime.now().toIso8601String()));
  }

  Future<List<Map<String, dynamic>>> schedule(String studentId) async {
    final courses = await myCourses(studentId);
    if (!useSupabase) {
      return courses
          .asMap()
          .entries
          .map((e) => {
                'id': 'h${e.key}',
                'dia_semana': e.key + 1,
                'hora_inicio': e.key.isEven ? '08:00' : '14:00',
                'hora_fin': e.key.isEven ? '10:00' : '16:00',
                'aula': e.value.room,
                'asignaciones': {
                  'materias': {'nombre': e.value.subjectName},
                  'docentes': {'nombres': e.value.teacherName, 'apellidos': ''}
                }
              })
          .toList();
    }
    final ids = courses.map((e) => e.id).toList();
    if (ids.isEmpty) return [];
    return List<Map<String, dynamic>>.from(await db
        .from('horarios')
        .select('*,asignaciones(materias(nombre),docentes(nombres,apellidos))')
        .inFilter('asignacion_id', ids)
        .order('dia_semana')
        .order('hora_inicio'));
  }

  Future<bool> hasCheckedIn(String studentId, String assignmentId) async {
    if (!useSupabase)
      return DemoAcademicStore.instance.attendance.any((x) =>
          x.studentId == studentId &&
          x.assignmentId == assignmentId &&
          x.date == DateTime.now().toIso8601String().substring(0, 10));
    final row = await db
        .from('marcaciones_asistencia')
        .select('id')
        .eq('estudiante_id', studentId)
        .eq('asignacion_id', assignmentId)
        .eq('fecha', DateTime.now().toIso8601String().substring(0, 10))
        .maybeSingle();
    return row != null;
  }

  Future<void> checkIn(String studentId, String assignmentId,
      {String? sessionId}) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (!useSupabase) {
      if (await hasCheckedIn(studentId, assignmentId))
        throw StateError('Ya marcaste asistencia hoy.');
      DemoAcademicStore.instance.attendance.add(Attendance(
          id: 'self${DateTime.now().microsecondsSinceEpoch}',
          assignmentId: assignmentId,
          studentId: studentId,
          date: today,
          status: 'Presente'));
      return;
    }
    if (sessionId == null)
      throw StateError('No existe una sesión de asistencia abierta.');
    await db.from('marcaciones_asistencia').insert({
      'estudiante_id': studentId,
      'asignacion_id': assignmentId,
      'sesion_id': sessionId,
      'fecha': today,
      'estado': 'Presente'
    });
  }

  Future<void> updateProfile(
      {required String names,
      required String lastNames,
      required String phone,
      required String career}) async {
    if (!useSupabase) {
      return;
    }
    await db.from('perfiles').update({
      'nombres': names.trim(),
      'apellidos': lastNames.trim(),
      'telefono': phone.trim(),
      'carrera': career.trim()
    }).eq('id', db.auth.currentUser!.id);
  }

  Future<List<Map<String, dynamic>>> documents(String studentId) async {
    if (!useSupabase) return List.unmodifiable(_demoDocuments);
    return List<Map<String, dynamic>>.from(await db
        .from('documentos_estudiante')
        .select()
        .eq('estudiante_id', studentId)
        .order('created_at', ascending: false));
  }

  Future<void> uploadDocument(
      {required String studentId,
      required String name,
      required Uint8List bytes,
      String? assignmentId}) async {
    if (bytes.length > 10485760)
      throw ArgumentError('El archivo supera el límite de 10 MB.');
    if (!useSupabase) {
      _demoDocuments.insert(0, {
        'id': 'doc${DateTime.now().microsecondsSinceEpoch}',
        'nombre': name,
        'tamano_bytes': bytes.length,
        'created_at': DateTime.now().toIso8601String()
      });
      return;
    }
    final userId = db.auth.currentUser!.id;
    final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    await db.storage.from('documentos-estudiantes').uploadBinary(path, bytes,
        fileOptions: const FileOptions(upsert: false));
    try {
      await db.from('documentos_estudiante').insert({
        'estudiante_id': studentId,
        'asignacion_id': assignmentId,
        'nombre': name,
        'ruta': path,
        'tamano_bytes': bytes.length
      });
    } catch (_) {
      await db.storage.from('documentos-estudiantes').remove([path]);
      rethrow;
    }
  }

  Future<void> deleteDocument(Map<String, dynamic> doc) async {
    if (!useSupabase) {
      _demoDocuments.removeWhere((x) => x['id'] == doc['id']);
      return;
    }
    await db.storage
        .from('documentos-estudiantes')
        .remove([doc['ruta'].toString()]);
    await db.from('documentos_estudiante').delete().eq('id', doc['id']);
  }

  Future<List<CourseAssignment>> myCourses(String studentId) async {
    if (!useSupabase) {
      final ens = DemoAcademicStore.instance.enrollments
          .where((e) => e.studentId == studentId);
      return DemoAcademicStore.instance.assignments
          .where((a) => ens
              .any((e) => e.courseId == a.courseId && e.periodId == a.periodId))
          .toList();
    }
    final enrollments = await db
        .from('matriculas')
        .select('curso_id,periodo_id')
        .eq('estudiante_id', studentId)
        .eq('estado', 'Inscrito');
    final result = <CourseAssignment>[];
    for (final e in enrollments) {
      final rows = await db
          .from('asignaciones')
          .select('*,cursos(*),materias(*),docentes(*),periodos(*)')
          .eq('curso_id', e['curso_id'])
          .eq('periodo_id', e['periodo_id']);
      result.addAll(
          rows.map<CourseAssignment>((r) => CourseAssignment.fromMap(r)));
    }
    return result;
  }

  Future<StudentCourseData> courseData(
      String studentId, CourseAssignment a) async {
    if (!useSupabase) {
      final store = DemoAcademicStore.instance;
      final evalIds = store.evaluations
          .where((e) => e.assignmentId == a.id)
          .map((e) => e.id);
      return StudentCourseData(
          assignment: a,
          grades: store.grades
              .where((g) =>
                  g.studentId == studentId && evalIds.contains(g.evaluationId))
              .map((g) {
            final ev =
                store.evaluations.firstWhere((e) => e.id == g.evaluationId);
            return {
              'titulo': ev.title,
              'nota': g.score,
              'ponderacion': ev.weight
            };
          }).toList(),
          attendance: store.attendance
              .where((x) => x.studentId == studentId && x.assignmentId == a.id)
              .map((x) => {'estado': x.status, 'fecha': x.date})
              .toList(),
          announcements: store.announcements);
    }
    final gradeRows = await db
        .from('calificaciones')
        .select('nota,evaluaciones!inner(titulo,ponderacion,asignacion_id)')
        .eq('estudiante_id', studentId)
        .eq('evaluaciones.asignacion_id', a.id);
    final attendanceRows = await db
        .from('asistencias')
        .select('estado,fecha')
        .eq('estudiante_id', studentId)
        .eq('asignacion_id', a.id);
    final announcementRows = await db
        .from('anuncios')
        .select()
        .eq('asignacion_id', a.id)
        .eq('activo', true)
        .order('publicado_en', ascending: false);
    return StudentCourseData(
        assignment: a,
        grades: gradeRows
            .map<Map<String, dynamic>>((r) => {
                  'titulo': r['evaluaciones']['titulo'],
                  'ponderacion': r['evaluaciones']['ponderacion'],
                  'nota': r['nota']
                })
            .toList(),
        attendance: List<Map<String, dynamic>>.from(attendanceRows),
        announcements: announcementRows
            .map<Announcement>((r) => Announcement.fromMap(r))
            .toList());
  }
}
