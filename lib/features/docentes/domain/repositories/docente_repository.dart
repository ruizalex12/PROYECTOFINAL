import '../entities/docente.dart';

abstract interface class DocenteRepository {
  Future<List<Docente>> listar({String? busqueda, bool? estado});

  Future<Docente> actualizar({
    required String id,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  });

  Future<Docente> cambiarEstado({required String id, required bool estado});
}
