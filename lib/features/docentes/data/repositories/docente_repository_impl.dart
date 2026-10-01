import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/docente.dart';
import '../../domain/repositories/docente_repository.dart';
import '../datasources/docente_remote_datasource.dart';

class DocenteRepositoryImpl implements DocenteRepository {
  DocenteRepositoryImpl(this._datasource);

  final DocenteRemoteDatasource _datasource;

  @override
  Future<List<Docente>> listar({String? busqueda, bool? estado}) =>
      _datasource.listar(busqueda: busqueda, estado: estado);

  @override
  Future<Docente> actualizar({
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
  Future<Docente> cambiarEstado({required String id, required bool estado}) =>
      _datasource.cambiarEstado(id: id, estado: estado);

  String? _optional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  Future<Docente> _mapDuplicate(
    Future<Docente> Function() operation,
  ) async {
    try {
      return await operation();
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const AppException('Ya existe un docente con este CI.');
      }
      rethrow;
    }
  }
}
