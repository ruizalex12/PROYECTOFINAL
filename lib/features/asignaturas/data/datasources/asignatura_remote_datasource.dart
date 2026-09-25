import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/asignatura_model.dart';

class AsignaturaRemoteDatasource {
  AsignaturaRemoteDatasource(this._client);

  final SupabaseClient _client;

  Future<List<AsignaturaModel>> listar() async {
    final rows = await _client
        .schema('public')
        .from('asignatura')
        .select()
        .order('codigo', ascending: true);
    return rows.map(AsignaturaModel.fromMap).toList(growable: false);
  }

  Future<AsignaturaModel> crear({
    required String codigo,
    required String nombre,
    String? descripcion,
  }) async {
    final row = await _client
        .schema('public')
        .from('asignatura')
        .insert({
          'codigo': codigo,
          'nombre': nombre,
          'descripcion': descripcion,
          'estado': true,
        })
        .select()
        .single();
    return AsignaturaModel.fromMap(row);
  }

  Future<AsignaturaModel> actualizar({
    required int id,
    required String codigo,
    required String nombre,
    String? descripcion,
  }) async {
    final row = await _client
        .schema('public')
        .from('asignatura')
        .update({
          'codigo': codigo,
          'nombre': nombre,
          'descripcion': descripcion,
        })
        .eq('id_asignatura', id)
        .select()
        .single();
    return AsignaturaModel.fromMap(row);
  }

  Future<AsignaturaModel> cambiarEstado({
    required int id,
    required bool estado,
  }) async {
    final row = await _client
        .schema('public')
        .from('asignatura')
        .update({'estado': estado})
        .eq('id_asignatura', id)
        .select()
        .single();
    return AsignaturaModel.fromMap(row);
  }
}
