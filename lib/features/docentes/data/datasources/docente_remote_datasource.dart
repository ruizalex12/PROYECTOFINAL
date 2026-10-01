import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/docente_model.dart';

class DocenteRemoteDatasource {
  DocenteRemoteDatasource(this._client);

  final SupabaseClient _client;

  Future<List<DocenteModel>> listar({
    String? busqueda,
    bool? estado,
  }) async {
    var query = _client
        .schema('public')
        .from('perfil_usuario')
        .select()
        .eq('rol', 'DOCENTE');
    if (estado != null) query = query.eq('estado', estado);
    final search = _safeSearch(busqueda);
    if (search.isNotEmpty) {
      query = query.or(
        'nombres.ilike.%$search%,'
        'apellidos.ilike.%$search%,'
        'ci.ilike.%$search%,'
        'correo.ilike.%$search%',
      );
    }
    final rows = await query.order('apellidos').order('nombres');
    return rows.map(DocenteModel.fromMap).toList(growable: false);
  }

  Future<DocenteModel> actualizar({
    required String id,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) async {
    final row = await _client
        .schema('public')
        .from('perfil_usuario')
        .update({
          'nombres': nombres,
          'apellidos': apellidos,
          'ci': ci,
          'telefono': telefono,
        })
        .eq('id', id)
        .eq('rol', 'DOCENTE')
        .select()
        .single();
    return DocenteModel.fromMap(row);
  }

  Future<DocenteModel> cambiarEstado({
    required String id,
    required bool estado,
  }) async {
    final row = await _client
        .schema('public')
        .from('perfil_usuario')
        .update({'estado': estado})
        .eq('id', id)
        .eq('rol', 'DOCENTE')
        .select()
        .single();
    return DocenteModel.fromMap(row);
  }

  String _safeSearch(String? value) =>
      value
          ?.trim()
          .replaceAll(RegExp(r'[,().%_*]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ') ??
      '';
}
