import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/reporte_academico.dart';

class ReporteRemoteDatasource {
  ReporteRemoteDatasource(this._client);
  final SupabaseClient _client;

  Future<ReporteOptions> cargarOpciones() async {
    final rows = await Future.wait([
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
          .from('estudiante')
          .select('id_estudiante,nombres,apellidos,codigo')
          .order('apellidos')
          .order('nombres'),
      _client
          .schema('public')
          .from('perfil_usuario')
          .select('id,nombres,apellidos')
          .eq('rol', 'DOCENTE')
          .order('apellidos')
          .order('nombres'),
    ]);
    return ReporteOptions(
      periodos: rows[0]
          .map((e) => ReporteOption<int>(
              (e['id_periodo'] as num).toInt(), e['nombre'].toString()))
          .toList(),
      asignaturas: rows[1]
          .map((e) => ReporteOption<int>(
              (e['id_asignatura'] as num).toInt(), e['nombre'].toString()))
          .toList(),
      estudiantes: rows[2].map((e) {
        final codigo = e['codigo']?.toString().trim();
        final nombre = '${e['nombres']} ${e['apellidos']}'.trim();
        return ReporteOption<int>((e['id_estudiante'] as num).toInt(),
            codigo == null || codigo.isEmpty ? nombre : '$nombre ($codigo)');
      }).toList(),
      docentes: rows[3]
          .map((e) => ReporteOption<String>(
              e['id'].toString(), '${e['nombres']} ${e['apellidos']}'.trim()))
          .toList(),
    );
  }

  Future<List<ReporteInscripcionItem>> inscripciones(
      ReporteFilter filter) async {
    var query = _client.schema('public').from('inscripcion').select('''
      id_inscripcion,fecha_inscripcion,estado,estudiante_id,asignatura_id,periodo_id,
      estudiante:estudiante!inner(id_estudiante,codigo,ci,nombres,apellidos),
      asignatura:asignatura!inner(id_asignatura,nombre),
      periodo:periodo_academico!inner(id_periodo,nombre)
    ''');
    if (filter.periodoId != null) {
      query = query.eq('periodo_id', filter.periodoId!);
    }
    if (filter.asignaturaId != null) {
      query = query.eq('asignatura_id', filter.asignaturaId!);
    }
    if (filter.estudianteId != null) {
      query = query.eq('estudiante_id', filter.estudianteId!);
    }
    if (filter.estado != null) query = query.eq('estado', filter.estado!);
    final rows = await query.order('fecha_inscripcion', ascending: false);
    return rows.map((row) {
      final estudiante = row['estudiante'] as Map<String, dynamic>;
      final asignatura = row['asignatura'] as Map<String, dynamic>;
      final periodo = row['periodo'] as Map<String, dynamic>;
      return ReporteInscripcionItem(
        id: (row['id_inscripcion'] as num).toInt(),
        estudianteId: (row['estudiante_id'] as num).toInt(),
        estudiante:
            '${estudiante['nombres']} ${estudiante['apellidos']}'.trim(),
        codigo: estudiante['codigo']?.toString() ?? '-',
        ci: estudiante['ci'].toString(),
        asignatura: asignatura['nombre'].toString(),
        periodo: periodo['nombre'].toString(),
        fecha: DateTime.parse(row['fecha_inscripcion'].toString()),
        estado: row['estado'] as bool,
      );
    }).toList(growable: false);
  }

  Future<List<ReporteAsignacionItem>> asignaciones(ReporteFilter filter) async {
    var query = _client.schema('public').from('asignacion_docente').select('''
      id_asignacion,fecha_asignacion,estado,docente_id,asignatura_id,periodo_id,
      docente:perfil_usuario!inner(id,nombres,apellidos,rol),
      asignatura:asignatura!inner(id_asignatura,nombre),
      periodo:periodo_academico!inner(id_periodo,nombre)
    ''').eq('docente.rol', 'DOCENTE');
    if (filter.periodoId != null) {
      query = query.eq('periodo_id', filter.periodoId!);
    }
    if (filter.asignaturaId != null) {
      query = query.eq('asignatura_id', filter.asignaturaId!);
    }
    if (filter.docenteId != null) {
      query = query.eq('docente_id', filter.docenteId!);
    }
    if (filter.estado != null) query = query.eq('estado', filter.estado!);
    final rows = await query.order('fecha_asignacion', ascending: false);
    return rows.map((row) {
      final docente = row['docente'] as Map<String, dynamic>;
      final asignatura = row['asignatura'] as Map<String, dynamic>;
      final periodo = row['periodo'] as Map<String, dynamic>;
      return ReporteAsignacionItem(
        id: (row['id_asignacion'] as num).toInt(),
        docente: '${docente['nombres']} ${docente['apellidos']}'.trim(),
        asignatura: asignatura['nombre'].toString(),
        periodo: periodo['nombre'].toString(),
        fecha: DateTime.parse(row['fecha_asignacion'].toString()),
        estado: row['estado'] as bool,
      );
    }).toList(growable: false);
  }
}
