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
        .select('*, datos_docente(*)')
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
    String? direccion,
    required String sexo,
    required DateTime fechaNacimiento,
    required String especialidad,
    String? tituloProfesional,
    String? gradoAcademico,
    DateTime? fechaIncorporacion,
    String? observaciones,
  }) async {
    final profileRow = await _client
        .schema('public')
        .from('perfil_usuario')
        .update(buildProfileUpdate(
          nombres: nombres,
          apellidos: apellidos,
          ci: ci,
          telefono: telefono,
          direccion: direccion,
          sexo: sexo,
          fechaNacimiento: fechaNacimiento,
        ))
        .eq('id', id)
        .eq('rol', 'DOCENTE')
        .select()
        .single();
    final professionalRow = await _client
        .schema('public')
        .from('datos_docente')
        .upsert(
            buildProfessionalUpsert(
              id: id,
              especialidad: especialidad,
              tituloProfesional: tituloProfesional,
              gradoAcademico: gradoAcademico,
              fechaIncorporacion: fechaIncorporacion,
              observaciones: observaciones,
            ),
            onConflict: 'usuario_id')
        .select()
        .single();
    return DocenteModel.fromMap({
      ...profileRow,
      'datos_docente': professionalRow,
    });
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

  static Map<String, dynamic> buildProfileUpdate({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
    String? direccion,
    required String sexo,
    required DateTime fechaNacimiento,
  }) =>
      {
        'nombres': nombres,
        'apellidos': apellidos,
        'ci': ci,
        'telefono': telefono,
        'direccion': direccion,
        'sexo': sexo,
        'fecha_nacimiento': _date(fechaNacimiento),
      };

  static Map<String, dynamic> buildProfessionalUpsert({
    required String id,
    required String especialidad,
    String? tituloProfesional,
    String? gradoAcademico,
    DateTime? fechaIncorporacion,
    String? observaciones,
  }) =>
      {
        'usuario_id': id,
        'especialidad': especialidad,
        'titulo_profesional': tituloProfesional,
        'grado_academico': gradoAcademico,
        'fecha_incorporacion':
            fechaIncorporacion == null ? null : _date(fechaIncorporacion),
        'observaciones': observaciones,
      };

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
