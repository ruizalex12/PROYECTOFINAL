import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/calificacion_model.dart';

class CalificacionRemoteDatasource {
  CalificacionRemoteDatasource(this._client);

  final SupabaseClient _client;

  Future<List<CalificacionModel>> listarPorAsignacion(
    int asignacionId,
  ) async {
    final rows = await _client
        .schema('public')
        .from('calificacion')
        .select()
        .eq('asignacion_docente_id', asignacionId)
        .order('fecha_registro', ascending: false);
    return rows.map(CalificacionModel.fromMap).toList(growable: false);
  }

  Future<CalificacionModel> crear({
    required int inscripcionId,
    required int asignacionId,
    required String tipoEvaluacion,
    required double nota,
    String? observacion,
  }) async {
    final row = await _client
        .schema('public')
        .from('calificacion')
        .insert({
          'inscripcion_id': inscripcionId,
          'asignacion_docente_id': asignacionId,
          'tipo_evaluacion': tipoEvaluacion,
          'nota': nota,
          'observacion': observacion,
        })
        .select()
        .single();
    return CalificacionModel.fromMap(row);
  }

  Future<CalificacionModel> actualizar({
    required int id,
    required int inscripcionId,
    required int asignacionId,
    required String tipoEvaluacion,
    required double nota,
    String? observacion,
  }) async {
    final row = await _client
        .schema('public')
        .from('calificacion')
        .update({
          'inscripcion_id': inscripcionId,
          'asignacion_docente_id': asignacionId,
          'tipo_evaluacion': tipoEvaluacion,
          'nota': nota,
          'observacion': observacion,
        })
        .eq('id_calificacion', id)
        .select()
        .single();
    return CalificacionModel.fromMap(row);
  }
}
