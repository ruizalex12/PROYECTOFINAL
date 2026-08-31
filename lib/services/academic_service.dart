import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/academic_entities.dart';
import 'demo_academic_store.dart';

class AcademicService {
  AcademicService({required this.useSupabase});
  final bool useSupabase;
  static final Map<String, List<Map<String, dynamic>>> demoRows = {
    'estudiantes': [
      {
        'id': 'e1',
        'codigo': 'EST-001',
        'nombres': 'María',
        'apellidos': 'Flores',
        'email': 'maria@demo.edu',
        'telefono': '72900001'
      }
    ],
    'docentes': [
      {
        'id': 'd1',
        'codigo': 'DOC-001',
        'nombres': 'Carlos',
        'apellidos': 'Mendoza',
        'email': 'carlos@demo.edu',
        'especialidad': 'Tecnología educativa'
      }
    ],
    'materias': [
      {
        'id': 'm1',
        'codigo': 'INF-101',
        'nombre': 'Programación I',
        'creditos': 5,
        'horas_semanales': 6
      }
    ],
    'cursos': [
      {
        'id': 'c1',
        'nombre': 'Primer semestre',
        'paralelo': 'A',
        'gestion': '2026',
        'cupo': 35
      }
    ],
    'periodos': [
      {
        'id': 'p1',
        'nombre': 'Gestión II/2026',
        'fecha_inicio': '2026-08-01',
        'fecha_fin': '2026-12-15',
        'estado': 'Activo'
      }
    ],
  };
  SupabaseClient get _client => Supabase.instance.client;
  Future<List<Map<String, dynamic>>> list(String table) async {
    if (!useSupabase)
      return List<Map<String, dynamic>>.from(demoRows[table] ?? const []);
    final rows = await _client
        .from(table)
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> save(String table, Map<String, dynamic> values,
      {String? id}) async {
    if (!useSupabase) {
      final rows = demoRows.putIfAbsent(table, () => []);
      if (id == null) {
        final row = {
          ...values,
          'id': DateTime.now().microsecondsSinceEpoch.toString()
        };
        rows.insert(0, row);
        _syncDemoInsert(table, row);
      } else {
        final i = rows.indexWhere((e) => e['id'] == id);
        if (i >= 0) rows[i] = {...rows[i], ...values};
      }
      return;
    }
    if (id == null) {
      await _client.from(table).insert(values);
    } else {
      await _client.from(table).update(values).eq('id', id);
    }
  }

  void _syncDemoInsert(String table, Map<String, dynamic> row) {
    final store = DemoAcademicStore.instance;
    if (table == 'estudiantes') store.students.add(Student.fromMap(row));
    if (table == 'docentes') store.teachers.add(Teacher.fromMap(row));
    if (table == 'materias') store.subjects.add(Subject.fromMap(row));
    if (table == 'cursos') store.courses.add(Course.fromMap(row));
    if (table == 'periodos') store.periods.add(AcademicPeriod.fromMap(row));
  }

  Future<void> remove(String table, String id) async {
    if (!useSupabase) {
      demoRows[table]?.removeWhere((e) => e['id'] == id);
      return;
    }
    await _client.from(table).delete().eq('id', id);
  }

  Future<Map<String, int>> dashboardCounts() async {
    final result = <String, int>{};
    for (final table in ['estudiantes', 'docentes', 'materias', 'cursos']) {
      result[table] = (await list(table)).length;
    }
    return result;
  }
}
