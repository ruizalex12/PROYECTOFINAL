import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/consulta_calificacion.dart';
import '../models/consulta_calificacion_model.dart';

class ConsultaCalificacionRemoteDatasource {
  ConsultaCalificacionRemoteDatasource(this._client);
  final SupabaseClient _client;

  static const _select = '''
    id_calificacion,
    tipo_evaluacion,
    nota,
    observacion,
    fecha_registro,
    inscripcion:inscripcion!inner(
      id_inscripcion,
      estudiante_id,
      asignatura_id,
      periodo_id,
      estudiante:estudiante!inner(
        id_estudiante,
        codigo,
        nombres,
        apellidos,
        ci
      ),
      asignatura:asignatura!inner(id_asignatura,nombre),
      periodo:periodo_academico!inner(id_periodo,nombre)
    ),
    asignacion:asignacion_docente!inner(
      id_asignacion,
      docente_id,
      docente:perfil_usuario!inner(id,nombres,apellidos,rol)
    )
  ''';

  Future<List<ConsultaCalificacionModel>> listar(
    CalificacionAdminFilter filter,
  ) async {
    var query = _client
        .schema('public')
        .from('calificacion')
        .select(_select)
        .eq('asignacion.docente.rol', 'DOCENTE');
    if (filter.periodoId != null) {
      query = query.eq('inscripcion.periodo_id', filter.periodoId!);
    }
    if (filter.asignaturaId != null) {
      query = query.eq('inscripcion.asignatura_id', filter.asignaturaId!);
    }
    if (filter.estudianteId != null) {
      query = query.eq('inscripcion.estudiante_id', filter.estudianteId!);
    }
    if (filter.docenteId != null) {
      query = query.eq('asignacion.docente_id', filter.docenteId!);
    }
    if (filter.tipoEvaluacion != null) {
      query = query.eq('tipo_evaluacion', filter.tipoEvaluacion!);
    }
    if (filter.notaMinima != null) {
      query = query.gte('nota', filter.notaMinima!);
    }
    if (filter.notaMaxima != null) {
      query = query.lte('nota', filter.notaMaxima!);
    }
    final rows = await query.order('fecha_registro', ascending: false);
    var items =
        rows.map(ConsultaCalificacionModel.fromMap).toList(growable: false);
    final search = filter.busqueda.trim().toLowerCase();
    if (search.isNotEmpty) {
      items = items.where((item) {
        final text = [
          item.estudianteNombre,
          item.estudianteCi,
          item.estudianteCodigo ?? '',
          item.asignaturaNombre,
          item.docenteNombre,
          item.tipoEvaluacion,
        ].join(' ').toLowerCase();
        return text.contains(search);
      }).toList(growable: false);
    }
    items.sort((a, b) {
      final byDate = b.fechaRegistro.compareTo(a.fechaRegistro);
      return byDate != 0
          ? byDate
          : a.estudianteNombre.compareTo(b.estudianteNombre);
    });
    return items;
  }

  Future<CalificacionAdminOptions> cargarOpciones() async {
    final results = await Future.wait([
      _client
          .schema('public')
          .from('periodo_academico')
          .select('id_periodo,nombre')
          .order('fecha_inicio', ascending: false),
      _client
          .schema('public')
          .from('asignatura')
          .select('id_asignatura,nombre')
          .order('nombre'),
      _client
          .schema('public')
          .from('perfil_usuario')
          .select('id,nombres,apellidos')
          .eq('rol', 'DOCENTE')
          .order('apellidos')
          .order('nombres'),
      _client
          .schema('public')
          .from('calificacion')
          .select('tipo_evaluacion')
          .not('tipo_evaluacion', 'is', null)
          .order('tipo_evaluacion'),
    ]);
    final tipos = results[3]
        .map((row) => row['tipo_evaluacion']?.toString().trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false)
      ..sort();
    return CalificacionAdminOptions(
      periodos: results[0]
          .map((row) => CalificacionAdminOption<int>(
                id: (row['id_periodo'] as num).toInt(),
                label: row['nombre'].toString(),
              ))
          .toList(growable: false),
      asignaturas: results[1]
          .map((row) => CalificacionAdminOption<int>(
                id: (row['id_asignatura'] as num).toInt(),
                label: row['nombre'].toString(),
              ))
          .toList(growable: false),
      docentes: results[2]
          .map((row) => CalificacionAdminOption<String>(
                id: row['id'].toString(),
                label: '${row['nombres']} ${row['apellidos']}'.trim(),
              ))
          .toList(growable: false),
      tiposEvaluacion: tipos,
    );
  }
}
