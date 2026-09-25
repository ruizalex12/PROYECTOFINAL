import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/layouts/admin_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/asignatura.dart';
import '../controllers/asignatura_controller.dart';
import '../widgets/asignatura_card.dart';
import '../widgets/asignatura_form_dialog.dart';
import '../widgets/asignatura_table.dart';

enum _EstadoFiltro { todas, activas, inactivas }

class AsignaturasPage extends StatefulWidget {
  const AsignaturasPage({super.key});

  @override
  State<AsignaturasPage> createState() => _AsignaturasPageState();
}

class _AsignaturasPageState extends State<AsignaturasPage> {
  final _busqueda = TextEditingController();
  _EstadoFiltro _filtro = _EstadoFiltro.todas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AsignaturaController>().cargar());
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<Asignatura> _filtrar(List<Asignatura> items) {
    final query = _busqueda.text.trim().toLowerCase();
    return items.where((item) {
      final matchesQuery = query.isEmpty ||
          item.codigo.toLowerCase().contains(query) ||
          item.nombre.toLowerCase().contains(query) ||
          (item.descripcion?.toLowerCase().contains(query) ?? false);
      final matchesState = switch (_filtro) {
        _EstadoFiltro.todas => true,
        _EstadoFiltro.activas => item.estado,
        _EstadoFiltro.inactivas => !item.estado,
      };
      return matchesQuery && matchesState;
    }).toList(growable: false);
  }

  Future<void> _form([Asignatura? asignatura]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AsignaturaController>(),
          child: AsignaturaFormDialog(asignatura: asignatura)),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(asignatura == null
            ? 'Asignatura creada correctamente.'
            : 'Asignatura actualizada correctamente.')));
  }

  Future<void> _toggle(Asignatura asignatura) async {
    final activating = !asignatura.estado;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
            activating
                ? Icons.check_circle_outline
                : Icons.pause_circle_outline,
            color: activating ? AppColors.success : AppColors.danger,
            size: 34),
        title:
            Text(activating ? 'Reactivar asignatura' : 'Desactivar asignatura'),
        content: Text(
            '¿Confirma que desea ${activating ? 'reactivar' : 'desactivar'} “${asignatura.nombre}”?',
            textAlign: TextAlign.center),
        actions: [
          OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(activating ? 'Reactivar' : 'Desactivar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final error =
        await context.read<AsignaturaController>().cambiarEstado(asignatura);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error ??
            (activating
                ? 'Asignatura reactivada correctamente.'
                : 'Asignatura desactivada correctamente.'))));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AsignaturaController>();
    return AdminShell(
      selectedRoute: RouteNames.adminAsignaturas,
      title: 'Asignaturas',
      child: Padding(
        padding:
            EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: 'Gestión de asignaturas',
                  subtitle: 'Administre la oferta académica del seminario.',
                  action: FilledButton.icon(
                      onPressed: () => _form(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Nueva asignatura')),
                ),
                const SizedBox(height: 22),
                _Filters(
                  controller: _busqueda,
                  selected: _filtro,
                  onSearch: (_) => setState(() {}),
                  onFilter: (value) => setState(() => _filtro = value),
                ),
                const SizedBox(height: 18),
                Expanded(child: _buildState(controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildState(AsignaturaController controller) =>
      switch (controller.state) {
        AsignaturaViewState.loading => const Card(
            child: AppLoadingState(message: 'Cargando asignaturas...')),
        AsignaturaViewState.empty => const Card(
            child: AppEmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No existen asignaturas registradas.',
                message:
                    'Seleccione “Nueva asignatura” para registrar la primera.')),
        AsignaturaViewState.error => Card(
            child: AppErrorState(
                message: controller.errorMessage ??
                    'No fue posible cargar las asignaturas.',
                onRetry: controller.cargar)),
        AsignaturaViewState.data => _DataView(
            items: _filtrar(controller.items),
            onEdit: _form,
            onToggle: _toggle),
      };
}

class _Filters extends StatelessWidget {
  const _Filters(
      {required this.controller,
      required this.selected,
      required this.onSearch,
      required this.onFilter});
  final TextEditingController controller;
  final _EstadoFiltro selected;
  final ValueChanged<String> onSearch;
  final ValueChanged<_EstadoFiltro> onFilter;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final search = TextField(
                controller: controller,
                onChanged: onSearch,
                decoration: const InputDecoration(
                    hintText: 'Buscar por código, nombre o descripción',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true));
            final filter = SegmentedButton<_EstadoFiltro>(
              segments: const [
                ButtonSegment(value: _EstadoFiltro.todas, label: Text('Todas')),
                ButtonSegment(
                    value: _EstadoFiltro.activas, label: Text('Activas')),
                ButtonSegment(
                    value: _EstadoFiltro.inactivas, label: Text('Inactivas'))
              ],
              selected: {selected},
              showSelectedIcon: false,
              onSelectionChanged: (values) => onFilter(values.first),
            );
            return compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        search,
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal, child: filter)
                      ])
                : Row(children: [
                    Expanded(child: search),
                    const SizedBox(width: 14),
                    filter
                  ]);
          }),
        ),
      );
}

class _DataView extends StatelessWidget {
  const _DataView(
      {required this.items, required this.onEdit, required this.onToggle});
  final List<Asignatura> items;
  final ValueChanged<Asignatura> onEdit;
  final ValueChanged<Asignatura> onToggle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Card(
          child: AppEmptyState(
              icon: Icons.search_off_rounded,
              title: 'Sin resultados',
              message: 'Cambie la búsqueda o los filtros seleccionados.'));
    }
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 760) {
        return SingleChildScrollView(
            child: AsignaturaTable(
                items: items, onEdit: onEdit, onToggle: onToggle));
      }
      return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) => AsignaturaCard(
              asignatura: items[index],
              onEdit: () => onEdit(items[index]),
              onToggle: () => onToggle(items[index])));
    });
  }
}
