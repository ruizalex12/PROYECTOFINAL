import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/layouts/admin_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/estudiante.dart';
import '../controllers/estudiante_controller.dart';
import '../widgets/estudiante_filters.dart';
import '../widgets/estudiante_form_dialog.dart';
import '../widgets/estudiante_table.dart';

class EstudiantesPage extends StatefulWidget {
  const EstudiantesPage({super.key});

  @override
  State<EstudiantesPage> createState() => _EstudiantesPageState();
}

class _EstudiantesPageState extends State<EstudiantesPage> {
  final _searchController = TextEditingController();
  EstudianteEstadoFiltro _estado = EstudianteEstadoFiltro.todos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<EstudianteController>().cargar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _buscar() => context.read<EstudianteController>().cargar(
        busqueda: _searchController.text,
        estado: _estado.value,
      );

  Future<void> _limpiar() async {
    _searchController.clear();
    setState(() => _estado = EstudianteEstadoFiltro.todos);
    await context.read<EstudianteController>().cargar(reset: true);
  }

  Future<void> _form([Estudiante? estudiante]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<EstudianteController>(),
        child: EstudianteFormDialog(estudiante: estudiante),
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          estudiante == null
              ? 'Estudiante registrado correctamente.'
              : 'Estudiante actualizado correctamente.',
        ),
      ),
    );
  }

  Future<void> _toggle(Estudiante estudiante) async {
    final activating = !estudiante.estado;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          activating ? 'Reactivar estudiante' : 'Desactivar estudiante',
        ),
        content: Text(
          '¿Confirma que desea ${activating ? 'reactivar' : 'desactivar'} a '
          '${estudiante.nombreCompleto}?',
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
        await context.read<EstudianteController>().cambiarEstado(estudiante);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (activating
                  ? 'Estudiante reactivado correctamente.'
                  : 'Estudiante desactivado correctamente.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EstudianteController>();
    return AdminShell(
      selectedRoute: RouteNames.adminEstudiantes,
      title: 'Estudiantes',
      child: Padding(
        padding:
            EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: 'Gestión de estudiantes',
                  subtitle:
                      'Administra la información académica básica de los estudiantes.',
                  action: FilledButton.icon(
                    onPressed: controller.state == EstudianteViewState.loading
                        ? null
                        : () => _form(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nuevo estudiante'),
                  ),
                ),
                const SizedBox(height: 22),
                EstudianteFilters(
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

  Widget _body(EstudianteController controller) => switch (controller.state) {
        EstudianteViewState.loading => const Card(
            child: AppLoadingState(message: 'Cargando estudiantes...'),
          ),
        EstudianteViewState.empty => Card(
            child: AppEmptyState(
              icon: controller.hasFilters
                  ? Icons.search_off_rounded
                  : Icons.school_outlined,
              title: controller.hasFilters
                  ? 'No se encontraron estudiantes con los criterios seleccionados.'
                  : 'No existen estudiantes registrados.',
              message: controller.hasFilters
                  ? 'Cambie los filtros o limpie la búsqueda.'
                  : 'Seleccione Nuevo estudiante para registrar el primero.',
            ),
          ),
        EstudianteViewState.error => Card(
            child: AppErrorState(
              message: controller.errorMessage ??
                  'No fue posible cargar los estudiantes.',
              onRetry: controller.cargar,
            ),
          ),
        EstudianteViewState.data => _data(controller.items),
      };

  Widget _data(List<Estudiante> items) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 760) {
            return SingleChildScrollView(
              child: EstudianteTable(
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
                      Text(
                        item.codigo == null
                            ? 'Sin código'
                            : 'Código: ${item.codigo}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
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
