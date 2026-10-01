import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/periodo_academico_model.dart';

class PeriodoAcademicoRemoteDatasource {
  PeriodoAcademicoRemoteDatasource(this._client);

  final SupabaseClient _client;

  Future<List<PeriodoAcademicoModel>> listar({
    String? busqueda,
    bool? estado,
  }) async {
    var query = _client.schema('public').from('periodo_academico').select();
    if (estado != null) query = query.eq('estado', estado);
    final search = _safeSearch(busqueda);
    if (search.isNotEmpty) query = query.ilike('nombre', '%$search%');
    final rows = await query.order('fecha_inicio', ascending: false);
    return rows.map(PeriodoAcademicoModel.fromMap).toList(growable: false);
  }

  Future<List<PeriodoAcademicoModel>> listarActivos() async {
    final rows = await _client
        .schema('public')
        .from('periodo_academico')
        .select()
        .eq('estado', true)
        .order('fecha_inicio', ascending: false);
    return rows.map(PeriodoAcademicoModel.fromMap).toList(growable: false);
  }

  Future<PeriodoAcademicoModel> crear({
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final row = await _client
        .schema('public')
        .from('periodo_academico')
        .insert({
          'nombre': nombre,
          'fecha_inicio': _date(fechaInicio),
          'fecha_fin': _date(fechaFin),
          'estado': true,
        })
        .select()
        .single();
    return PeriodoAcademicoModel.fromMap(row);
  }

  Future<PeriodoAcademicoModel> actualizar({
    required int id,
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final row = await _client
        .schema('public')
        .from('periodo_academico')
        .update({
          'nombre': nombre,
          'fecha_inicio': _date(fechaInicio),
          'fecha_fin': _date(fechaFin),
        })
        .eq('id_periodo', id)
        .select()
        .single();
    return PeriodoAcademicoModel.fromMap(row);
  }

  Future<PeriodoAcademicoModel> cambiarEstado({
    required int id,
    required bool estado,
  }) async {
    final row = await _client
        .schema('public')
        .from('periodo_academico')
        .update({'estado': estado})
        .eq('id_periodo', id)
        .select()
        .single();
    return PeriodoAcademicoModel.fromMap(row);
  }

  String _date(DateTime value) => '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  String _safeSearch(String? value) =>
      value
          ?.trim()
          .replaceAll(RegExp(r'[%_*]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ') ??
      '';
}
