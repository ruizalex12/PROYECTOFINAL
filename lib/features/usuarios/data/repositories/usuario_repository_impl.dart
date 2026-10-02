import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../datasources/usuario_remote_datasource.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  UsuarioRepositoryImpl(this._datasource);

  final UsuarioRemoteDatasource _datasource;

  @override
  Future<List<Usuario>> listar({
    String? busqueda,
    UsuarioRol? rol,
    bool? estado,
  }) =>
      _datasource.listar(busqueda: busqueda, rol: rol, estado: estado);

  @override
  Future<Usuario> crear({
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
  }) =>
      _datasource.crear(
        nombres: nombres.trim(),
        apellidos: apellidos.trim(),
        ci: ci.trim(),
        telefono: _optional(telefono),
        direccion: _optional(direccion),
        sexo: sexo,
        fechaNacimiento: _optional(fechaNacimiento),
        correo: correo.trim().toLowerCase(),
        contrasena: contrasena,
        rol: rol,
        docente: docente == null
            ? null
            : DatosDocenteCreacion(
                especialidad: docente.especialidad.trim(),
                tituloProfesional: _optional(docente.tituloProfesional),
                gradoAcademico: _optional(docente.gradoAcademico),
                fechaIncorporacion: _optional(docente.fechaIncorporacion),
                observaciones: _optional(docente.observaciones),
              ),
      );

  @override
  Future<Usuario> actualizar({
    required String id,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) =>
      _mapDuplicate(
        () => _datasource.actualizar(
          id: id,
          nombres: nombres.trim(),
          apellidos: apellidos.trim(),
          ci: ci.trim(),
          telefono: _optional(telefono),
        ),
      );

  @override
  Future<Usuario> cambiarEstado({required String id, required bool estado}) =>
      _datasource.cambiarEstado(id: id, estado: estado);

  String? _optional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  Future<Usuario> _mapDuplicate(Future<Usuario> Function() operation) async {
    try {
      return await operation();
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const AppException('Ya existe un usuario con este CI.');
      }
      rethrow;
    }
  }
}
