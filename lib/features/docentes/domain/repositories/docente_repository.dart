import '../entities/docente.dart';

abstract interface class DocenteRepository {
  Future<List<Docente>> listar({String? busqueda, bool? estado});

  Future<Docente> actualizar({
    required String id,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
    String? direccion,
    required String sexo,
    required DateTime fechaNacimiento,
    required String especialidad,
    String? tituloProfesional,
    String? gradoAcademico,
    DateTime? fechaIncorporacion,
    String? observaciones,
  });

  Future<Docente> cambiarEstado({required String id, required bool estado});
}
