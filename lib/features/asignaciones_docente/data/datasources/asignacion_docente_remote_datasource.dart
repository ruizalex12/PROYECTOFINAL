import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/asignacion_docente.dart';
import '../models/asignacion_docente_model.dart';

class AsignacionDocenteRemoteDatasource {
  AsignacionDocenteRemoteDatasource(this._client);

  final SupabaseClient _client;

  static const _select = '''
    id_asignacion,
    docente_id,
    asignatura_id,
    periodo_id,
    fecha_asignacion,
    estado,
    docente:perfil_usuario!inner(
      id,
      correo,
      nombres,
      apellidos,
      rol,
      estado
    ),
    asignatura!inner(
      id_asignatura,
      codigo,
      nombre,
      descripcion,
      estado,
      fecha_registro
    ),
    periodo_academico!inner(
      id_periodo,
      nombre,
      fecha_inicio,
      fecha_fin,
      estado
    )
  ''';

  Future<List<AsignacionDocenteModel>> listarPropiasActivas() async {
    final rows = await _client
        .schema('public')
        .from('asignacion_docente')
        .select(_select)
        .eq('estado', true)
        .eq('asignatura.estado', true)
        .eq('periodo_academico.estado', true)
        .order('fecha_asignacion', ascending: false);

    return rows.map(AsignacionDocenteModel.fromMap).toList(growable: false);
  }

  Future<List<AsignacionDocenteModel>> listar() async {
    final rows = await _client
        .schema('public')
        .from('asignacion_docente')
        .select(_select)
        .order('fecha_asignacion', ascending: false);
    return rows.map(AsignacionDocenteModel.fromMap).toList(growable: false);
  }

  Future<List<DocenteOption>> listarDocentesActivos() async {
    final rows = await _client
        .schema('public')
        .from('perfil_usuario')
        .select('id, correo, nombres, apellidos')
        .eq('rol', 'DOCENTE')
        .eq('estado', true)
        .order('apellidos')
        .order('nombres');
    return rows
        .map(
          (row) => DocenteOption(
            id: row['id'].toString(),
            nombre: '${row['nombres']} ${row['apellidos']}'.trim(),
            correo: row['correo'].toString(),
          ),
        )
        .toList(growable: false);
  }

  Future<List<AsignaturaOption>> listarAsignaturasActivas() async {
    final rows = await _client
        .schema('public')
        .from('asignatura')
        .select('id_asignatura, codigo, nombre')
        .eq('estado', true)
        .order('codigo');
    return rows
        .map(
          (row) => AsignaturaOption(
            id: (row['id_asignatura'] as num).toInt(),
            codigo: row['codigo'].toString(),
            nombre: row['nombre'].toString(),
          ),
        )
        .toList(growable: false);
  }

  Future<List<PeriodoOption>> listarPeriodosActivos() async {
    final rows = await _client
        .schema('public')
        .from('periodo_academico')
        .select('id_periodo, nombre')
        .eq('estado', true)
        .order('fecha_inicio', ascending: false);
    return rows
        .map(
          (row) => PeriodoOption(
            id: (row['id_periodo'] as num).toInt(),
            nombre: row['nombre'].toString(),
          ),
        )
        .toList(growable: false);
  }

  Future<AsignacionDocenteModel> crear({
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  }) async {
    final row = await _client
        .schema('public')
        .from('asignacion_docente')
        .insert({
          'docente_id': docenteId,
          'asignatura_id': asignaturaId,
          'periodo_id': periodoId,
          'estado': true,
        })
        .select(_select)
        .single();
    return AsignacionDocenteModel.fromMap(row);
  }

  Future<AsignacionDocenteModel> actualizar({
    required int id,
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  }) async {
    final row = await _client
        .schema('public')
        .from('asignacion_docente')
        .update({
          'docente_id': docenteId,
          'asignatura_id': asignaturaId,
          'periodo_id': periodoId,
        })
        .eq('id_asignacion', id)
        .select(_select)
        .single();
    return AsignacionDocenteModel.fromMap(row);
  }

  Future<AsignacionDocenteModel> cambiarEstado({
    required int id,
    required bool estado,
  }) async {
    final row = await _client
        .schema('public')
        .from('asignacion_docente')
        .update({'estado': estado})
        .eq('id_asignacion', id)
        .select(_select)
        .single();
    return AsignacionDocenteModel.fromMap(row);
  }
}
