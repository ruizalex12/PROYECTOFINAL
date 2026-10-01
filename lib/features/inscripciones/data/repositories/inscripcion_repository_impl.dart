import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/inscripcion.dart';
import '../../domain/repositories/inscripcion_repository.dart';
import '../datasources/inscripcion_remote_datasource.dart';

class InscripcionRepositoryImpl implements InscripcionRepository {
  InscripcionRepositoryImpl(this._datasource);

  final InscripcionRemoteDatasource _datasource;

  @override
  Future<List<Inscripcion>> listar() => _datasource.listar();

  @override
  Future<InscripcionOptions> cargarOpciones() async {
    final values = await Future.wait([
      _datasource.listarEstudiantesActivos(),
      _datasource.listarAsignaturasActivas(),
      _datasource.listarPeriodosActivos(),
    ]);
    return InscripcionOptions(
      estudiantes: values[0],
      asignaturas: values[1],
      periodos: values[2],
    );
  }

  @override
  Future<Inscripcion> crear({
    required int estudianteId,
    required int asignaturaId,
    required int periodoId,
  }) =>
      _mapErrors(
        () => _datasource.crear(
          estudianteId: estudianteId,
          asignaturaId: asignaturaId,
          periodoId: periodoId,
        ),
      );

  @override
  Future<Inscripcion> actualizar({
    required int id,
    required int estudianteId,
    required int asignaturaId,
    required int periodoId,
  }) =>
      _mapErrors(
        () => _datasource.actualizar(
          id: id,
          estudianteId: estudianteId,
          asignaturaId: asignaturaId,
          periodoId: periodoId,
        ),
      );

  @override
  Future<Inscripcion> cambiarEstado({required int id, required bool estado}) =>
      _mapErrors(() => _datasource.cambiarEstado(id: id, estado: estado));

  Future<Inscripcion> _mapErrors(
    Future<Inscripcion> Function() operation,
  ) async {
    try {
      return await operation();
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const AppException(
          'El estudiante ya se encuentra inscrito en esta asignatura para el periodo seleccionado.',
        );
      }
      final message = error.message.toLowerCase();
      if (message.contains('estudiante_inactivo')) {
        throw const AppException(
          'El estudiante seleccionado no se encuentra activo.',
        );
      }
      if (message.contains('asignatura_inactiva')) {
        throw const AppException(
          'La asignatura seleccionada no se encuentra activa.',
        );
      }
      if (message.contains('periodo_inactivo')) {
        throw const AppException(
          'El periodo académico seleccionado no se encuentra activo.',
        );
      }
      rethrow;
    }
  }
}
