import '../entities/asignacion_docente.dart';

abstract interface class AsignacionDocenteRepository {
  Future<List<AsignacionDocente>> listarPropiasActivas();

  Future<List<AsignacionDocente>> listar();

  Future<AsignacionDocenteOptions> cargarOpciones();

  Future<AsignacionDocente> crear({
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  });

  Future<AsignacionDocente> actualizar({
    required int id,
    required String docenteId,
    required int asignaturaId,
    required int periodoId,
  });

  Future<AsignacionDocente> cambiarEstado({
    required int id,
    required bool estado,
  });
}
