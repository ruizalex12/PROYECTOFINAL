import '../../domain/entities/asignatura.dart';
import '../../domain/repositories/asignatura_repository.dart';
import '../datasources/asignatura_remote_datasource.dart';

class AsignaturaRepositoryImpl implements AsignaturaRepository {
  AsignaturaRepositoryImpl(this._datasource);

  final AsignaturaRemoteDatasource _datasource;

  @override
  Future<List<Asignatura>> listar() => _datasource.listar();

  @override
  Future<Asignatura> crear({
    required String codigo,
    required String nombre,
    String? descripcion,
  }) {
    return _datasource.crear(
      codigo: _normalizarCodigo(codigo),
      nombre: nombre.trim(),
      descripcion: _descripcion(descripcion),
    );
  }

  @override
  Future<Asignatura> actualizar({
    required int id,
    required String codigo,
    required String nombre,
    String? descripcion,
  }) {
    return _datasource.actualizar(
      id: id,
      codigo: _normalizarCodigo(codigo),
      nombre: nombre.trim(),
      descripcion: _descripcion(descripcion),
    );
  }

  @override
  Future<Asignatura> cambiarEstado({required int id, required bool estado}) {
    return _datasource.cambiarEstado(id: id, estado: estado);
  }

  String _normalizarCodigo(String value) => value.trim().toUpperCase();

  String? _descripcion(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
