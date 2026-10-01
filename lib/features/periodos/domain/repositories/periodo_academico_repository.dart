import '../entities/periodo_academico.dart';

abstract interface class PeriodoAcademicoRepository {
  Future<List<PeriodoAcademico>> listar({String? busqueda, bool? estado});

  Future<PeriodoAcademico> crear({
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });

  Future<PeriodoAcademico> actualizar({
    required int id,
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });

  Future<PeriodoAcademico> cambiarEstado({
    required int id,
    required bool estado,
  });

  Future<List<PeriodoAcademico>> listarActivos();
}
