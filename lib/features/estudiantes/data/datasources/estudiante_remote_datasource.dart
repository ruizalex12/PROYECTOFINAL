import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/estudiante_inscrito_model.dart';
import '../models/estudiante_model.dart';

class EstudianteRemoteDatasource {
  EstudianteRemoteDatasource(this._client);

  final SupabaseClient _client;

  Future<List<EstudianteModel>> listar({
    String? busqueda,
    bool? estado,
  }) async {
    var query = _client.schema('public').from('estudiante').select();
    if (estado != null) query = query.eq('estado', estado);
    final search = _safeSearch(busqueda);
    if (search.isNotEmpty) {
      query = query.or(
        'codigo.ilike.%$search%,'
        'nombres.ilike.%$search%,'
        'apellidos.ilike.%$search%,'
        'ci.ilike.%$search%',
      );
    }
    final rows = await query.order('apellidos').order('nombres');
    return rows.map(EstudianteModel.fromMap).toList(growable: false);
  }

  Future<EstudianteModel> crear({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) async {
    final row = await _client
        .schema('public')
        .from('estudiante')
        .insert(EstudianteModel.createPayload(
          nombres: nombres,
          apellidos: apellidos,
          ci: ci,
          telefono: telefono,
        ))
        .select()
        .single();
    return EstudianteModel.fromMap(row);
  }

  Future<EstudianteModel> actualizar({
    required int id,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) async {
    final row = await _client
        .schema('public')
        .from('estudiante')
        .update(EstudianteModel.updatePayload(
          nombres: nombres,
          apellidos: apellidos,
          ci: ci,
          telefono: telefono,
        ))
        .eq('id_estudiante', id)
        .select()
        .single();
    return EstudianteModel.fromMap(row);
  }

  Future<EstudianteModel> cambiarEstado({
    required int id,
    required bool estado,
  }) async {
    final row = await _client
        .schema('public')
        .from('estudiante')
        .update({'estado': estado})
        .eq('id_estudiante', id)
        .select()
        .single();
    return EstudianteModel.fromMap(row);
  }

  Future<int> contarActivos() async {
    final rows = await _client
        .schema('public')
        .from('estudiante')
        .select('id_estudiante')
        .eq('estado', true);
    return rows.length;
  }

  Future<List<EstudianteInscritoModel>> listarPorAsignacion(
    int asignacionId,
  ) async {
    final asignacion = await _client
        .schema('public')
        .from('asignacion_docente')
        .select('asignatura_id, periodo_id')
        .eq('id_asignacion', asignacionId)
        .eq('estado', true)
        .maybeSingle();

    if (asignacion == null) {
      throw const AppException(
        'La asignación no existe o no está autorizada.',
      );
    }

    final rows = await _client
        .schema('public')
        .from('inscripcion')
        .select('''
          id_inscripcion,
          estado,
          estudiante!inner(
            id_estudiante,
            codigo,
            nombres,
            apellidos,
            ci,
            telefono,
            estado
          )
        ''')
        .eq('asignatura_id', asignacion['asignatura_id'] as Object)
        .eq('periodo_id', asignacion['periodo_id'] as Object)
        .eq('estado', true)
        .eq('estudiante.estado', true)
        .order('apellidos', referencedTable: 'estudiante')
        .order('nombres', referencedTable: 'estudiante');

    return rows.map(EstudianteInscritoModel.fromMap).toList(growable: false);
  }

  String _safeSearch(String? value) =>
      value
          ?.trim()
          .replaceAll(RegExp(r'[,().%_*]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ') ??
      '';
}
