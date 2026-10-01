import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/asignacion_docente.dart';
import '../../domain/repositories/asignacion_docente_repository.dart';
import '../datasources/asignacion_docente_remote_datasource.dart';

class AsignacionDocenteRepositoryImpl implements AsignacionDocenteRepository {
  AsignacionDocenteRepositoryImpl(this._datasource);

  final AsignacionDocenteRemoteDatasource _datasource;

  @override
  Future<List<AsignacionDocente>> listarPropiasActivas() =>
      _datasource.listarPropiasActivas();

  @override
  Future<List<AsignacionDocente>> listar() => _datasource.listar();

  @override
  Future<AsignacionDocenteOptions> cargarOpciones() async {
    final results = await Future.wait([
      _datasource.listarDocentesActivos(),
      _datasource.listarAsignaturasActivas(),
      _datasource.listarPeriodosActivos(),
    ]);
    return AsignacionDocenteOptions(
      docentes: results[0] as List<DocenteOption>,
      asignaturas: results[1] as List<AsignaturaOption>,
      periodos: results[2] as List<PeriodoOption>,
    );
  }

  @override
  Future<AsignacionDocente> crear({
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  }) =>
      _mapDuplicate(
        () => _datasource.crear(
          docenteId: docenteId,
          asignaturaId: asignaturaId,
          periodoId: periodoId,
        ),
      );

  @override
  Future<AsignacionDocente> actualizar({
    required int id,
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  }) =>
      _mapDuplicate(
        () => _datasource.actualizar(
          id: id,
          docenteId: docenteId,
          asignaturaId: asignaturaId,
          periodoId: periodoId,
        ),
      );

  @override
  Future<AsignacionDocente> cambiarEstado({
    required int id,
    required bool estado,
  }) =>
      _datasource.cambiarEstado(id: id, estado: estado);

  Future<AsignacionDocente> _mapDuplicate(
    Future<AsignacionDocente> Function() operation,
  ) async {
    try {
      return await operation();
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const AppException(
          'El docente ya se encuentra asignado a esta asignatura en el periodo seleccionado.',
        );
      }
      rethrow;
    }
  }
}
