import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/estudiante.dart';
import '../../domain/entities/estudiante_inscrito.dart';
import '../../domain/repositories/estudiante_repository.dart';
import '../datasources/estudiante_remote_datasource.dart';

class EstudianteRepositoryImpl implements EstudianteRepository {
  EstudianteRepositoryImpl(this._datasource);

  final EstudianteRemoteDatasource _datasource;

  @override
  Future<List<EstudianteInscrito>> listarPorAsignacion(int asignacionId) =>
      _datasource.listarPorAsignacion(asignacionId);

  @override
  Future<List<Estudiante>> listar({String? busqueda, bool? estado}) =>
      _datasource.listar(busqueda: busqueda, estado: estado);

  @override
  Future<Estudiante> crear({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) =>
      _mapDuplicate(
        () => _datasource.crear(
          nombres: nombres.trim(),
          apellidos: apellidos.trim(),
          ci: ci.trim(),
          telefono: _optional(telefono),
        ),
      );

  @override
  Future<Estudiante> actualizar({
    required int id,
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
  Future<Estudiante> cambiarEstado({required int id, required bool estado}) =>
      _datasource.cambiarEstado(id: id, estado: estado);

  @override
  Future<int> contarActivos() => _datasource.contarActivos();

  String? _optional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  Future<Estudiante> _mapDuplicate(
    Future<Estudiante> Function() operation,
  ) async {
    try {
      return await operation();
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        final detail = '${error.message} ${error.details}'.toLowerCase();
        if (detail.contains('codigo') ||
            detail.contains('estudiante_codigo_key')) {
          throw const AppException(
            'Ya existe un estudiante registrado con este código.',
          );
        }
        throw const AppException(
          'Ya existe un estudiante registrado con este CI.',
        );
      }
      rethrow;
    }
  }
}
