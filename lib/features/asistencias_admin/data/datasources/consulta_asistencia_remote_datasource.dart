import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../asistencia/domain/entities/asistencia.dart';
import '../../domain/entities/consulta_asistencia.dart';
import '../models/consulta_asistencia_model.dart';

class ConsultaAsistenciaRemoteDatasource {
  ConsultaAsistenciaRemoteDatasource(this._client);

  final SupabaseClient _client;

  static const _select = '''
    id_asistencia,
    fecha,
    estado,
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
      asignatura:asignatura!inner(
        id_asignatura,
        nombre
      ),
      periodo:periodo_academico!inner(
        id_periodo,
        nombre
      )
    ),
    asignacion:asignacion_docente!inner(
      id_asignacion,
      docente_id,
      docente:perfil_usuario!inner(
        id,
        nombres,
        apellidos,
        rol
      )
    )
  ''';

  Future<List<ConsultaAsistenciaModel>> listar(
    AsistenciaAdminFilter filter,
  ) async {
    var query = _client
        .schema('public')
        .from('asistencia')
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
    if (filter.estado != null) {
      query = query.eq('estado', filter.estado!.databaseValue);
    }
    if (filter.fechaDesde != null) {
      query = query.gte('fecha', _date(filter.fechaDesde!));
    }
    if (filter.fechaHasta != null) {
      query = query.lte('fecha', _date(filter.fechaHasta!));
    }

    final rows = await query.order('fecha', ascending: false);
    var items =
        rows.map(ConsultaAsistenciaModel.fromMap).toList(growable: false);
    final search = filter.busqueda.trim().toLowerCase();
    if (search.isNotEmpty) {
      items = items.where((item) {
        final text = [
          item.estudianteNombre,
          item.estudianteCi,
          item.estudianteCodigo ?? '',
          item.asignaturaNombre,
          item.docenteNombre,
        ].join(' ').toLowerCase();
        return text.contains(search);
      }).toList(growable: false);
    }
    items.sort((a, b) {
      final byDate = b.fecha.compareTo(a.fecha);
      return byDate != 0
          ? byDate
          : a.estudianteNombre.compareTo(b.estudianteNombre);
    });
    return items;
  }

  Future<AsistenciaAdminOptions> cargarOpciones() async {
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
    ]);
    final periodos = results[0];
    final asignaturas = results[1];
    final docentes = results[2];
    return AsistenciaAdminOptions(
      periodos: periodos
          .map((row) => AsistenciaAdminOption<int>(
                id: (row['id_periodo'] as num).toInt(),
                label: row['nombre'].toString(),
              ))
          .toList(growable: false),
      asignaturas: asignaturas
          .map((row) => AsistenciaAdminOption<int>(
                id: (row['id_asignatura'] as num).toInt(),
                label: row['nombre'].toString(),
              ))
          .toList(growable: false),
      docentes: docentes
          .map((row) => AsistenciaAdminOption<String>(
                id: row['id'].toString(),
                label: '${row['nombres']} ${row['apellidos']}'.trim(),
              ))
          .toList(growable: false),
    );
  }

  String _date(DateTime value) => '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
