import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/periodo_academico.dart';
import '../../domain/repositories/periodo_academico_repository.dart';
import '../datasources/periodo_academico_remote_datasource.dart';

class PeriodoAcademicoRepositoryImpl implements PeriodoAcademicoRepository {
  PeriodoAcademicoRepositoryImpl(this._datasource);

  final PeriodoAcademicoRemoteDatasource _datasource;

  @override
  Future<List<PeriodoAcademico>> listar({String? busqueda, bool? estado}) =>
      _datasource.listar(busqueda: busqueda, estado: estado);

  @override
  Future<List<PeriodoAcademico>> listarActivos() => _datasource.listarActivos();

  @override
  Future<PeriodoAcademico> crear({
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) =>
      _validateAndMap(
        () => _datasource.crear(
          nombre: nombre.trim(),
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
        ),
        fechaInicio,
        fechaFin,
      );

  @override
  Future<PeriodoAcademico> actualizar({
    required int id,
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) =>
      _validateAndMap(
        () => _datasource.actualizar(
          id: id,
          nombre: nombre.trim(),
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
        ),
        fechaInicio,
        fechaFin,
      );

  @override
  Future<PeriodoAcademico> cambiarEstado({
    required int id,
    required bool estado,
  }) =>
      _datasource.cambiarEstado(id: id, estado: estado);

  Future<PeriodoAcademico> _validateAndMap(
    Future<PeriodoAcademico> Function() operation,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    if (fechaFin.isBefore(fechaInicio)) {
      throw const AppException(
        'La fecha de finalización no puede ser anterior a la fecha de inicio.',
      );
    }
    try {
      return await operation();
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const AppException(
          'Ya existe un periodo académico con este nombre.',
        );
      }
      if (error.code == '23514') {
        throw const AppException(
          'La fecha de finalización no puede ser anterior a la fecha de inicio.',
        );
      }
      rethrow;
    }
  }
}
