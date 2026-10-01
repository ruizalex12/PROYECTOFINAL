import '../entities/estudiante.dart';
import '../entities/estudiante_inscrito.dart';

abstract interface class EstudianteRepository {
  Future<List<EstudianteInscrito>> listarPorAsignacion(int asignacionId);

  Future<List<Estudiante>> listar({String? busqueda, bool? estado});

  Future<Estudiante> crear({
    String? codigo,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  });

  Future<Estudiante> actualizar({
    required int id,
    String? codigo,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  });

  Future<Estudiante> cambiarEstado({required int id, required bool estado});

  Future<int> contarActivos();
}
