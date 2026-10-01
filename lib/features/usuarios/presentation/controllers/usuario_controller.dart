import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

enum UsuarioViewState { loading, empty, error, data }

class UsuarioController extends ChangeNotifier {
  UsuarioController(this._repository, {required this.currentUserId});

  final UsuarioRepository _repository;
  final String currentUserId;
  UsuarioViewState _state = UsuarioViewState.loading;
  List<Usuario> _items = const [];
  String? _errorMessage;
  bool _saving = false;
  String _busqueda = '';
  UsuarioRol? _rol;
  bool? _estado;

  UsuarioViewState get state => _state;
  List<Usuario> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  bool get saving => _saving;
  bool get hasFilters =>
      _busqueda.isNotEmpty || _rol != null || _estado != null;

  Future<void> cargar({
    String? busqueda,
    UsuarioRol? rol,
    bool? estado,
    bool reset = false,
  }) async {
    if (reset) {
      _busqueda = '';
      _rol = null;
      _estado = null;
    } else {
      if (busqueda != null) _busqueda = busqueda.trim();
      _rol = rol;
      _estado = estado;
    }
    _state = UsuarioViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.listar(
        busqueda: _busqueda,
        rol: _rol,
        estado: _estado,
      );
      _state = _items.isEmpty ? UsuarioViewState.empty : UsuarioViewState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = UsuarioViewState.error;
    }
    notifyListeners();
  }

  Future<String?> crear({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
    required String correo,
    required String contrasena,
    required UsuarioRol rol,
  }) async {
    _saving = true;
    notifyListeners();
    try {
      await _repository.crear(
        nombres: nombres,
        apellidos: apellidos,
        ci: ci,
        telefono: telefono,
        correo: correo,
        contrasena: contrasena,
        rol: rol,
      );
      await cargar(busqueda: _busqueda, rol: _rol, estado: _estado);
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<String?> actualizar({
    required Usuario usuario,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) async {
    _saving = true;
    notifyListeners();
    try {
      await _repository.actualizar(
        id: usuario.id,
        nombres: nombres,
        apellidos: apellidos,
        ci: ci,
        telefono: telefono,
      );
      await cargar(busqueda: _busqueda, rol: _rol, estado: _estado);
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<String?> cambiarEstado(Usuario usuario) async {
    if (usuario.estado && usuario.id == currentUserId) {
      return 'No puede desactivar su propia cuenta de administrador.';
    }
    try {
      await _repository.cambiarEstado(
        id: usuario.id,
        estado: !usuario.estado,
      );
      await cargar(busqueda: _busqueda, rol: _rol, estado: _estado);
      return null;
    } catch (error) {
      return ErrorMapper.message(error);
    }
  }
}
