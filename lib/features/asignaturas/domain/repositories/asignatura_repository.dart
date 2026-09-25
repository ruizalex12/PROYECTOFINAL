import '../entities/asignatura.dart';

abstract interface class AsignaturaRepository {
  Future<List<Asignatura>> listar();

  Future<Asignatura> crear({
    required String codigo,
    required String nombre,
    String? descripcion,
  });

  Future<Asignatura> actualizar({
    required int id,
    required String codigo,
    required String nombre,
    String? descripcion,
  });

  Future<Asignatura> cambiarEstado({required int id, required bool estado});
}
