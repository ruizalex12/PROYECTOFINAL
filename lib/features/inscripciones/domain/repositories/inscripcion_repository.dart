import '../entities/inscripcion.dart';

abstract interface class InscripcionRepository {
  Future<List<Inscripcion>> listar();
  Future<InscripcionOptions> cargarOpciones();
  Future<Inscripcion> crear({
    required int estudianteId,
    required int asignaturaId,
    required int periodoId,
  });
  Future<Inscripcion> actualizar({
    required int id,
    required int estudianteId,
    required int asignaturaId,
    required int periodoId,
  });
  Future<Inscripcion> cambiarEstado({required int id, required bool estado});
}
