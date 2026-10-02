import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/core/errors/app_exception.dart';
import 'package:proyecto_final_360/features/usuarios/domain/entities/usuario.dart';
import 'package:proyecto_final_360/features/usuarios/domain/repositories/usuario_repository.dart';
import 'package:proyecto_final_360/features/usuarios/presentation/controllers/usuario_controller.dart';
import 'package:proyecto_final_360/features/usuarios/presentation/widgets/usuario_form_validator.dart';

void main() {
  test('inicia en loading', () {
    expect(_controller(_FakeRepository()).state, UsuarioViewState.loading);
  });

  test('carga y lista usuarios', () async {
    final controller = _controller(_FakeRepository());
    await controller.cargar();
    expect(controller.state, UsuarioViewState.data);
    expect(controller.items, hasLength(3));
  });

  test('representa listado vacío', () async {
    final controller = _controller(_FakeRepository(items: []));
    await controller.cargar();
    expect(controller.state, UsuarioViewState.empty);
  });

  test('busca por nombres apellidos CI y correo', () async {
    for (final query in ['Ana', 'Admin', '111', 'ana@sfm.test']) {
      final controller = _controller(_FakeRepository());
      await controller.cargar(busqueda: query);
      expect(controller.items, [_admin]);
    }
  });

  test('filtra por rol', () async {
    final controller = _controller(_FakeRepository());
    await controller.cargar(rol: UsuarioRol.docente);
    expect(controller.items.every((item) => item.rol == UsuarioRol.docente),
        isTrue);
    expect(controller.items, hasLength(2));
  });

  test('filtra activos e inactivos', () async {
    final controller = _controller(_FakeRepository());
    await controller.cargar(estado: true);
    expect(controller.items, [_admin, _docente]);
    await controller.cargar(estado: false);
    expect(controller.items, [_inactivo]);
  });

  test('valida campos obligatorios', () {
    expect(UsuarioFormValidator.nombres(''), isNotNull);
    expect(UsuarioFormValidator.apellidos(' '), isNotNull);
    expect(UsuarioFormValidator.ci(null), isNotNull);
  });

  test('rechaza correo inválido', () {
    expect(UsuarioFormValidator.correo('correo-invalido'),
        'Ingrese un correo válido.');
  });

  test('rechaza contraseña corta', () {
    expect(UsuarioFormValidator.password('1234567'),
        'La contraseña debe tener al menos 8 caracteres.');
  });

  test('rechaza contraseñas distintas', () {
    expect(UsuarioFormValidator.confirmacion('otra', 'Segura123'),
        'Las contraseñas no coinciden.');
  });

  test('crea ADMINISTRADOR', () async {
    final repository = _FakeRepository(items: []);
    final error = await _controller(repository).crear(
      nombres: 'Ana',
      apellidos: 'Admin',
      ci: '111',
      correo: 'ana@sfm.test',
      contrasena: 'Segura123',
      rol: UsuarioRol.administrador,
    );
    expect(error, isNull);
    expect(repository.createdRole, UsuarioRol.administrador);
  });

  test('crea DOCENTE', () async {
    final repository = _FakeRepository(items: []);
    final error = await _controller(repository).crear(
      nombres: 'Luis',
      apellidos: 'Docente',
      ci: '222',
      correo: 'luis@sfm.test',
      contrasena: 'Segura123',
      rol: UsuarioRol.docente,
    );
    expect(error, isNull);
    expect(repository.createdRole, UsuarioRol.docente);
  });

  test('muestra correo duplicado', () async {
    final error = await _crearCon(_RuleErrorRepository(
      'Ya existe una cuenta con este correo.',
    ));
    expect(error, 'Ya existe una cuenta con este correo.');
  });

  test('muestra CI duplicado', () async {
    final error = await _crearCon(_RuleErrorRepository(
      'Ya existe un usuario con este CI.',
    ));
    expect(error, 'Ya existe un usuario con este CI.');
  });

  test('edita usuario', () async {
    final repository = _FakeRepository();
    final error = await _controller(repository).actualizar(
      usuario: _docente,
      nombres: 'Luis Alberto',
      apellidos: 'Docente',
      ci: '222',
    );
    expect(error, isNull);
    expect(repository.updated, isTrue);
  });

  test('desactiva usuario', () async {
    final repository = _FakeRepository();
    await _controller(repository).cambiarEstado(_docente);
    expect(repository.lastState, isFalse);
  });

  test('reactiva usuario', () async {
    final repository = _FakeRepository();
    await _controller(repository).cambiarEstado(_inactivo);
    expect(repository.lastState, isTrue);
  });

  test('impide auto-desactivación del administrador actual', () async {
    final repository = _FakeRepository();
    final error = await _controller(repository).cambiarEstado(_admin);
    expect(error, 'No puede desactivar su propia cuenta de administrador.');
    expect(repository.lastState, isNull);
  });

  test('maneja error del datasource', () async {
    final controller = _controller(_ErrorRepository());
    await controller.cargar();
    expect(controller.state, UsuarioViewState.error);
    expect(
        controller.errorMessage, 'No fue posible conectarse con el servidor.');
  });
}

UsuarioController _controller(UsuarioRepository repository) =>
    UsuarioController(repository, currentUserId: _admin.id);

Future<String?> _crearCon(UsuarioRepository repository) =>
    _controller(repository).crear(
      nombres: 'Ana',
      apellidos: 'Admin',
      ci: '111',
      correo: 'ana@sfm.test',
      contrasena: 'Segura123',
      rol: UsuarioRol.administrador,
    );

final _admin = Usuario(
  id: 'admin-1',
  correo: 'ana@sfm.test',
  nombres: 'Ana',
  apellidos: 'Admin',
  ci: '111',
  rol: UsuarioRol.administrador,
  estado: true,
  fechaRegistro: DateTime(2026, 1, 1),
);

final _docente = Usuario(
  id: 'docente-1',
  correo: 'luis@sfm.test',
  nombres: 'Luis',
  apellidos: 'Docente',
  ci: '222',
  rol: UsuarioRol.docente,
  estado: true,
  fechaRegistro: DateTime(2026, 1, 2),
);

final _inactivo = Usuario(
  id: 'docente-2',
  correo: 'maria@sfm.test',
  nombres: 'María',
  apellidos: 'Inactiva',
  ci: '333',
  rol: UsuarioRol.docente,
  estado: false,
  fechaRegistro: DateTime(2026, 1, 3),
);

class _FakeRepository implements UsuarioRepository {
  _FakeRepository({List<Usuario>? items})
      : items = items ?? [_admin, _docente, _inactivo];

  List<Usuario> items;
  UsuarioRol? createdRole;
  bool updated = false;
  bool? lastState;

  @override
  Future<List<Usuario>> listar({
    String? busqueda,
    UsuarioRol? rol,
    bool? estado,
  }) async {
    final query = busqueda?.trim().toLowerCase() ?? '';
    return items.where((item) {
      final text = [item.nombres, item.apellidos, item.ci, item.correo]
          .join(' ')
          .toLowerCase();
      return (rol == null || item.rol == rol) &&
          (estado == null || item.estado == estado) &&
          (query.isEmpty || text.contains(query));
    }).toList();
  }

  @override
  Future<Usuario> crear({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
    String? direccion,
    SexoUsuario? sexo,
    String? fechaNacimiento,
    required String correo,
    required String contrasena,
    required UsuarioRol rol,
    DatosDocenteCreacion? docente,
  }) async {
    createdRole = rol;
    final created = rol == UsuarioRol.docente ? _docente : _admin;
    items = [...items, created];
    return created;
  }

  @override
  Future<Usuario> actualizar({
    required String id,
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
  }) async {
    updated = true;
    return _docente;
  }

  @override
  Future<Usuario> cambiarEstado(
      {required String id, required bool estado}) async {
    lastState = estado;
    return estado ? _docente : _inactivo;
  }
}

class _RuleErrorRepository extends _FakeRepository {
  _RuleErrorRepository(this.message);
  final String message;

  @override
  Future<Usuario> crear({
    required String nombres,
    required String apellidos,
    required String ci,
    String? telefono,
    String? direccion,
    SexoUsuario? sexo,
    String? fechaNacimiento,
    required String correo,
    required String contrasena,
    required UsuarioRol rol,
    DatosDocenteCreacion? docente,
  }) =>
      throw AppException(message);
}

class _ErrorRepository extends _FakeRepository {
  @override
  Future<List<Usuario>> listar({
    String? busqueda,
    UsuarioRol? rol,
    bool? estado,
  }) =>
      throw Exception('Failed to fetch');
}
