import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/usuario.dart';
import '../models/usuario_model.dart';

class UsuarioRemoteDatasource {
  UsuarioRemoteDatasource(this._client);

  final SupabaseClient _client;

  Future<List<UsuarioModel>> listar({
    String? busqueda,
    UsuarioRol? rol,
    bool? estado,
  }) async {
    var query = _client.schema('public').from('perfil_usuario').select();
    if (rol != null) query = query.eq('rol', rol.databaseValue);
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
    return rows.map(UsuarioModel.fromMap).toList(growable: false);
  }

  Future<UsuarioModel> crear({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
    String? direccion,
    SexoUsuario? sexo,
    String? fechaNacimiento,
    required String correo,
    required String contrasena,
    required UsuarioRol rol,
    DatosDocenteCreacion? docente,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'crear-usuario',
        body: buildCreatePayload(
          nombres: nombres,
          apellidos: apellidos,
          ci: ci,
          telefono: telefono,
          direccion: direccion,
          sexo: sexo,
          fechaNacimiento: fechaNacimiento,
          correo: correo,
          contrasena: contrasena,
          rol: rol,
          docente: docente,
        ),
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      if (response.status < 200 || response.status >= 300) {
        throw AppException(
          data['message']?.toString() ?? 'No fue posible crear el usuario.',
        );
      }
      return UsuarioModel.fromMap(
        Map<String, dynamic>.from(data['usuario'] as Map),
      );
    } on FunctionException catch (error) {
      final details = error.details;
      if (details is Map && details['message'] != null) {
        throw AppException(details['message'].toString());
      }
      throw const AppException('No fue posible crear el usuario.');
    }
  }

  static Map<String, dynamic> buildCreatePayload({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
    String? direccion,
    SexoUsuario? sexo,
    String? fechaNacimiento,
    required String correo,
    required String contrasena,
    required UsuarioRol rol,
    DatosDocenteCreacion? docente,
  }) {
    final payload = <String, dynamic>{
      'nombres': nombres,
      'apellidos': apellidos,
      'ci': ci,
      'telefono': telefono,
      'direccion': direccion,
      'sexo': sexo?.databaseValue,
      'fechaNacimiento': fechaNacimiento,
      'correo': correo,
      'rol': rol.databaseValue,
      'password': contrasena,
    };
    if (rol == UsuarioRol.docente && docente != null) {
      payload['docente'] = <String, dynamic>{
        'especialidad': docente.especialidad,
        'tituloProfesional': docente.tituloProfesional,
        'gradoAcademico': docente.gradoAcademico,
        'fechaIncorporacion': docente.fechaIncorporacion,
        'observaciones': docente.observaciones,
      };
    }
    return payload;
  }

  Future<UsuarioModel> actualizar({
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
        .select()
        .single();
    return UsuarioModel.fromMap(row);
  }

  Future<UsuarioModel> cambiarEstado({
    required String id,
    required bool estado,
  }) async {
    if (!estado && id == _client.auth.currentUser?.id) {
      throw const AppException(
        'No puede desactivar su propia cuenta de administrador.',
      );
    }
    final row = await _client
        .schema('public')
        .from('perfil_usuario')
        .update({'estado': estado})
        .eq('id', id)
        .select()
        .single();
    return UsuarioModel.fromMap(row);
  }

  String _safeSearch(String? value) =>
      value
          ?.trim()
          .replaceAll(RegExp(r'[,().%_*]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ') ??
      '';
}
