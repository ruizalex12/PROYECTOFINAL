import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/route_names.dart';
import '../../../../shared/layouts/admin_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/usuario.dart';
import '../controllers/usuario_controller.dart';
import '../widgets/usuario_filters.dart';
import '../widgets/usuario_form_dialog.dart';
import '../widgets/usuario_table.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final _searchController = TextEditingController();
  UsuarioRolFiltro _rol = UsuarioRolFiltro.todos;
  UsuarioEstadoFiltro _estado = UsuarioEstadoFiltro.todos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<UsuarioController>().cargar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _buscar() => context.read<UsuarioController>().cargar(
        busqueda: _searchController.text,
        rol: _rol.value,
        estado: _estado.value,
      );

  Future<void> _limpiar() async {
    _searchController.clear();
    setState(() {
      _rol = UsuarioRolFiltro.todos;
      _estado = UsuarioEstadoFiltro.todos;
    });
    await context.read<UsuarioController>().cargar(reset: true);
  }

  Future<void> _form([Usuario? usuario]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<UsuarioController>(),
        child: UsuarioFormDialog(usuario: usuario),
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(usuario == null
          ? 'Usuario creado correctamente.'
          : 'Usuario actualizado correctamente.'),
    ));
  }

  Future<void> _toggle(Usuario usuario) async {
    final controller = context.read<UsuarioController>();
    if (usuario.estado && usuario.id == controller.currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No puede desactivar su propia cuenta de administrador.'),
      ));
      return;
    }
    final activating = !usuario.estado;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(activating ? 'Reactivar usuario' : 'Desactivar usuario'),
        content: Text(
          '¿Desea ${activating ? 'reactivar' : 'desactivar'} a '
          '${usuario.nombreCompleto}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(activating ? 'Reactivar' : 'Desactivar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final error = await controller.cambiarEstado(usuario);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ??
          (activating
              ? 'Usuario reactivado correctamente.'
              : 'Usuario desactivado correctamente.')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UsuarioController>();
    return AdminShell(
      selectedRoute: RouteNames.adminUsuarios,
      title: 'Usuarios',
      child: Padding(
        padding:
            EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: 'Gestión de Usuarios',
                  subtitle: 'Administra las cuentas con acceso al sistema.',
                  action: FilledButton.icon(
                    onPressed: controller.state == UsuarioViewState.loading
                        ? null
                        : () => _form(),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Nuevo usuario'),
                  ),
                ),
                const SizedBox(height: 22),
                UsuarioFilters(
                  key: ValueKey('$_rol-$_estado'),
                  searchController: _searchController,
                  rol: _rol,
                  estado: _estado,
                  onRol: (value) => setState(() => _rol = value),
                  onEstado: (value) => setState(() => _estado = value),
                  onBuscar: _buscar,
                  onLimpiar: _limpiar,
                ),
                const SizedBox(height: 18),
                Expanded(child: _body(controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(UsuarioController controller) => switch (controller.state) {
        UsuarioViewState.loading => const Card(
            child: AppLoadingState(message: 'Cargando usuarios...'),
          ),
        UsuarioViewState.empty => Card(
            child: AppEmptyState(
              icon: controller.hasFilters
                  ? Icons.search_off_rounded
                  : Icons.manage_accounts_outlined,
              title: controller.hasFilters
                  ? 'No se encontraron usuarios con los criterios seleccionados.'
                  : 'No existen usuarios registrados.',
              message: controller.hasFilters
                  ? 'Cambie los filtros o limpie la búsqueda.'
                  : 'Seleccione Nuevo usuario para registrar el primero.',
            ),
          ),
        UsuarioViewState.error => Card(
            child: AppErrorState(
              message: controller.errorMessage ??
                  'No fue posible cargar los usuarios.',
              onRetry: controller.cargar,
            ),
          ),
        UsuarioViewState.data => _data(controller.items),
      };

  Widget _data(List<Usuario> items) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return SingleChildScrollView(
              child: UsuarioTable(
                items: items,
                onEdit: _form,
                onToggle: _toggle,
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(item.nombreCompleto,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        StatusBadge(active: item.estado),
                      ]),
                      const SizedBox(height: 8),
                      Text(item.correo),
                      Text('CI: ${item.ci}'),
                      Text('Rol: ${item.rol.label}'),
                      const Divider(height: 24),
                      Wrap(alignment: WrapAlignment.end, children: [
                        TextButton(
                          onPressed: () => _form(item),
                          child: const Text('Editar'),
                        ),
                        TextButton(
                          onPressed: () => _toggle(item),
                          child: Text(item.estado ? 'Desactivar' : 'Reactivar'),
                        ),
                      ]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
}
