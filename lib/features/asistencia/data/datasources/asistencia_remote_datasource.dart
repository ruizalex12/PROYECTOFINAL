import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/asistencia.dart';
import '../models/asistencia_model.dart';

class AsistenciaRemoteDatasource {
  AsistenciaRemoteDatasource(this._client);

  final SupabaseClient _client;

  Future<List<AsistenciaModel>> listarPorFecha({
    required int asignacionId,
    required DateTime fecha,
  }) async {
    final rows = await _client
        .schema('public')
        .from('asistencia')
        .select()
        .eq('asignacion_docente_id', asignacionId)
        .eq('fecha', _date(fecha))
        .order('id_asistencia');
    return rows.map(AsistenciaModel.fromMap).toList(growable: false);
  }

  Future<List<AsistenciaModel>> guardarTodos(
    List<Asistencia> registros,
  ) async {
    if (registros.isEmpty) return const [];
    final values = registros
        .map(
          (item) => {
            'inscripcion_id': item.inscripcionId,
            'asignacion_docente_id': item.asignacionDocenteId,
            'fecha': _date(item.fecha),
            'estado': item.estado.databaseValue,
            'observacion': _optional(item.observacion),
          },
        )
        .toList(growable: false);

    final rows = await _client
        .schema('public')
        .from('asistencia')
        .upsert(
          values,
          onConflict: 'inscripcion_id,asignacion_docente_id,fecha',
        )
        .select();
    return rows.map(AsistenciaModel.fromMap).toList(growable: false);
  }

  String _date(DateTime value) => '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  String? _optional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
