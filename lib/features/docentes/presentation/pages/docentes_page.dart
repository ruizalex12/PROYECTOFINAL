import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/layouts/admin_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/docente.dart';
import '../controllers/docente_controller.dart';
import '../widgets/docente_filters.dart';
import '../widgets/docente_form_dialog.dart';
import '../widgets/docente_table.dart';

class DocentesPage extends StatefulWidget {
  const DocentesPage({super.key});

  @override
  State<DocentesPage> createState() => _DocentesPageState();
}

class _DocentesPageState extends State<DocentesPage> {
  final _searchController = TextEditingController();
  DocenteEstadoFiltro _estado = DocenteEstadoFiltro.todos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<DocenteController>().cargar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _buscar() => context.read<DocenteController>().cargar(
        busqueda: _searchController.text,
        estado: _estado.value,
      );

  Future<void> _limpiar() async {
    _searchController.clear();
    setState(() => _estado = DocenteEstadoFiltro.todos);
    await context.read<DocenteController>().cargar(reset: true);
  }

  Future<void> _form(Docente docente) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<DocenteController>(),
        child: DocenteFormDialog(docente: docente),
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Docente actualizado correctamente.',
        ),
      ),
    );
  }

  Future<void> _toggle(Docente docente) async {
    final activating = !docente.estado;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(activating ? 'Reactivar docente' : 'Desactivar docente'),
        content: Text(
          '¿Desea ${activating ? 'reactivar' : 'desactivar'} al docente '
          '${docente.nombreCompleto}?',
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
    final error =
        await context.read<DocenteController>().cambiarEstado(docente);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (activating
                  ? 'Docente reactivado correctamente.'
                  : 'Docente desactivado correctamente.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DocenteController>();
    return AdminShell(
      selectedRoute: RouteNames.adminDocentes,
      title: 'Docentes',
      child: Padding(
        padding:
            EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  title: 'Gestión de docentes',
                  subtitle:
                      'Gestiona perfiles DOCENTE existentes. Las cuentas nuevas se crean desde Usuarios.',
                ),
                const SizedBox(height: 22),
                DocenteFilters(
                  key: ValueKey(_estado),
                  searchController: _searchController,
                  estado: _estado,
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

  Widget _body(DocenteController controller) => switch (controller.state) {
        DocenteViewState.loading => const Card(
            child: AppLoadingState(message: 'Cargando docentes...'),
          ),
        DocenteViewState.empty => Card(
            child: AppEmptyState(
              icon: controller.hasFilters
                  ? Icons.search_off_rounded
                  : Icons.badge_outlined,
              title: controller.hasFilters
                  ? 'No se encontraron docentes con los criterios seleccionados.'
                  : 'No existen docentes registrados.',
              message: controller.hasFilters
                  ? 'Cambie los filtros o limpie la búsqueda.'
                  : 'Cree una cuenta con rol DOCENTE desde Gestión de Usuarios.',
            ),
          ),
        DocenteViewState.error => Card(
            child: AppErrorState(
              message:
                  controller.errorMessage ?? 'No fue posible cargar docentes.',
              onRetry: controller.cargar,
            ),
          ),
        DocenteViewState.data => _data(controller.items),
      };

  Widget _data(List<Docente> items) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) {
            return SingleChildScrollView(
              child: DocenteTable(
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.nombreCompleto,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          StatusBadge(active: item.estado),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('CI: ${item.ci}'),
                      Text(item.correo),
                      if (item.telefono != null)
                        Text(
                          'Teléfono: ${item.telefono}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _form(item),
                            child: const Text('Editar'),
                          ),
                          TextButton(
                            onPressed: () => _toggle(item),
                            child: Text(
                              item.estado ? 'Desactivar' : 'Reactivar',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
}
