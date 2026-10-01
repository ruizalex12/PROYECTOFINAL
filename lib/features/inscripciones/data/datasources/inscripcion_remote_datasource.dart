import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/inscripcion.dart';
import '../models/inscripcion_model.dart';

class InscripcionRemoteDatasource {
  InscripcionRemoteDatasource(this._client);

  final SupabaseClient _client;

  static const _select = '''
    id_inscripcion,
    estudiante_id,
    asignatura_id,
    periodo_id,
    fecha_inscripcion,
    estado,
    estudiante!inner(id_estudiante,nombres,apellidos,estado),
    asignatura!inner(id_asignatura,codigo,nombre,estado),
    periodo_academico!inner(id_periodo,nombre,estado)
  ''';

  Future<List<InscripcionModel>> listar() async {
    final rows = await _client
        .schema('public')
        .from('inscripcion')
        .select(_select)
        .order('fecha_inscripcion', ascending: false);
    return rows.map(InscripcionModel.fromMap).toList(growable: false);
  }

  Future<List<InscripcionOption>> listarEstudiantesActivos() async {
    final rows = await _client
        .schema('public')
        .from('estudiante')
        .select('id_estudiante,codigo,nombres,apellidos')
        .eq('estado', true)
        .order('apellidos')
        .order('nombres');
    return rows
        .map(
          (row) => InscripcionOption(
            id: (row['id_estudiante'] as num).toInt(),
            label: '${row['nombres']} ${row['apellidos']}'.trim(),
          ),
        )
        .toList(growable: false);
  }

  Future<List<InscripcionOption>> listarAsignaturasActivas() async {
    final rows = await _client
        .schema('public')
        .from('asignatura')
        .select('id_asignatura,codigo,nombre')
        .eq('estado', true)
        .order('codigo');
    return rows
        .map(
          (row) => InscripcionOption(
            id: (row['id_asignatura'] as num).toInt(),
            label: '${row['codigo']} · ${row['nombre']}',
          ),
        )
        .toList(growable: false);
  }

  Future<List<InscripcionOption>> listarPeriodosActivos() async {
    final rows = await _client
        .schema('public')
        .from('periodo_academico')
        .select('id_periodo,nombre')
        .eq('estado', true)
        .order('fecha_inicio', ascending: false);
    return rows
        .map(
          (row) => InscripcionOption(
            id: (row['id_periodo'] as num).toInt(),
            label: row['nombre'].toString(),
          ),
        )
        .toList(growable: false);
  }

  Future<InscripcionModel> crear({
    required int estudianteId,
    required int asignaturaId,
    required int periodoId,
  }) async {
    final row = await _client
        .schema('public')
        .from('inscripcion')
        .insert({
          'estudiante_id': estudianteId,
          'asignatura_id': asignaturaId,
          'periodo_id': periodoId,
          'estado': true,
        })
        .select(_select)
        .single();
    return InscripcionModel.fromMap(row);
  }

  Future<InscripcionModel> actualizar({
    required int id,
    required int estudianteId,
    required int asignaturaId,
    required int periodoId,
  }) async {
    final row = await _client
        .schema('public')
        .from('inscripcion')
        .update({
          'estudiante_id': estudianteId,
          'asignatura_id': asignaturaId,
          'periodo_id': periodoId,
        })
        .eq('id_inscripcion', id)
        .select(_select)
        .single();
    return InscripcionModel.fromMap(row);
  }

  Future<InscripcionModel> cambiarEstado({
    required int id,
    required bool estado,
  }) async {
    final row = await _client
        .schema('public')
        .from('inscripcion')
        .update({'estado': estado})
        .eq('id_inscripcion', id)
        .select(_select)
        .single();
    return InscripcionModel.fromMap(row);
  }
}
