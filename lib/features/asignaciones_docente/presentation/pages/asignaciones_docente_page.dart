import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/layouts/admin_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/asignacion_docente.dart';
import '../controllers/asignacion_docente_controller.dart';
import '../widgets/asignacion_docente_filters.dart';
import '../widgets/asignacion_docente_form_dialog.dart';
import '../widgets/asignacion_docente_table.dart';

class AsignacionesDocentePage extends StatefulWidget {
  const AsignacionesDocentePage({super.key});

  @override
  State<AsignacionesDocentePage> createState() =>
      _AsignacionesDocentePageState();
}

class _AsignacionesDocentePageState extends State<AsignacionesDocentePage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _docenteId;
  int? _asignaturaId;
  int? _periodoId;
  AsignacionEstadoFiltro _estado = AsignacionEstadoFiltro.todos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AsignacionDocenteController>().cargar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AsignacionDocente> _filtrar(List<AsignacionDocente> items) =>
      items.where((item) {
        final text = [
          item.docenteNombre,
          item.docenteCorreo,
          item.asignatura.codigo,
          item.asignatura.nombre,
          item.periodo.nombre,
        ].join(' ').toLowerCase();
        final matchesQuery = _query.isEmpty || text.contains(_query);
        final matchesDocente =
            _docenteId == null || item.docenteId == _docenteId;
        final matchesAsignatura =
            _asignaturaId == null || item.asignatura.id == _asignaturaId;
        final matchesPeriodo =
            _periodoId == null || item.periodo.id == _periodoId;
        final matchesEstado = switch (_estado) {
          AsignacionEstadoFiltro.todos => true,
          AsignacionEstadoFiltro.activas => item.estado,
          AsignacionEstadoFiltro.inactivas => !item.estado,
        };
        return matchesQuery &&
            matchesDocente &&
            matchesAsignatura &&
            matchesPeriodo &&
            matchesEstado;
      }).toList(growable: false);

  void _limpiar() {
    _searchController.clear();
    setState(() {
      _query = '';
      _docenteId = null;
      _asignaturaId = null;
      _periodoId = null;
      _estado = AsignacionEstadoFiltro.todos;
    });
  }

  Future<void> _form([AsignacionDocente? asignacion]) async {
    final controller = context.read<AsignacionDocenteController>();
    if (controller.options.docentes.isEmpty ||
        controller.options.asignaturas.isEmpty ||
        controller.options.periodos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe existir al menos un docente, una asignatura y un periodo activos.',
          ),
        ),
      );
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: AsignacionDocenteFormDialog(
          options: controller.options,
          asignacion: asignacion,
        ),
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          asignacion == null
              ? 'Asignación creada correctamente.'
              : 'Asignación actualizada correctamente.',
        ),
      ),
    );
  }

  Future<void> _toggle(AsignacionDocente asignacion) async {
    final activating = !asignacion.estado;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          activating ? 'Reactivar asignación' : 'Desactivar asignación',
        ),
        content: Text(
          '¿Confirma que desea ${activating ? 'reactivar' : 'desactivar'} '
          'la asignación de ${asignacion.docenteNombre} a '
          '${asignacion.asignatura.codigo}?',
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
    final error = await context
        .read<AsignacionDocenteController>()
        .cambiarEstado(asignacion);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (activating
                  ? 'Asignación reactivada correctamente.'
                  : 'Asignación desactivada correctamente.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AsignacionDocenteController>();
    return AdminShell(
      selectedRoute: RouteNames.adminAsignaciones,
      title: 'Asignaciones docentes',
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
                  title: 'Asignaciones docentes',
                  subtitle:
                      'Relaciona docentes con asignaturas y periodos académicos.',
                  action: FilledButton.icon(
                    onPressed:
                        controller.state == AsignacionDocenteViewState.loading
                            ? null
                            : () => _form(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nueva asignación'),
                  ),
                ),
                const SizedBox(height: 22),
                if (controller.state == AsignacionDocenteViewState.data) ...[
                  AsignacionDocenteFilters(
                    key: ValueKey(
                      '$_docenteId-$_asignaturaId-$_periodoId-$_estado',
                    ),
                    searchController: _searchController,
                    items: controller.items,
                    docenteId: _docenteId,
                    asignaturaId: _asignaturaId,
                    periodoId: _periodoId,
                    estado: _estado,
                    onDocente: (value) => setState(() => _docenteId = value),
                    onAsignatura: (value) =>
                        setState(() => _asignaturaId = value),
                    onPeriodo: (value) => setState(() => _periodoId = value),
                    onEstado: (value) => setState(() => _estado = value),
                    onBuscar: () => setState(
                      () =>
                          _query = _searchController.text.trim().toLowerCase(),
                    ),
                    onLimpiar: _limpiar,
                  ),
                  const SizedBox(height: 18),
                ],
                Expanded(child: _body(controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(AsignacionDocenteController controller) {
    return switch (controller.state) {
      AsignacionDocenteViewState.loading => const Card(
          child: AppLoadingState(message: 'Cargando asignaciones...'),
        ),
      AsignacionDocenteViewState.empty => const Card(
          child: AppEmptyState(
            icon: Icons.assignment_ind_outlined,
            title: 'No existen asignaciones docentes registradas.',
            message: 'Seleccione Nueva asignación para registrar la primera.',
          ),
        ),
      AsignacionDocenteViewState.error => Card(
          child: AppErrorState(
            message: controller.errorMessage ??
                'No fue posible cargar las asignaciones docentes.',
            onRetry: controller.cargar,
          ),
        ),
      AsignacionDocenteViewState.data => _data(_filtrar(controller.items)),
    };
  }

  Widget _data(List<AsignacionDocente> items) {
    if (items.isEmpty) {
      return const Card(
        child: AppEmptyState(
          icon: Icons.search_off_rounded,
          title: 'No se encontraron asignaciones.',
          message: 'Cambie los filtros o limpie la búsqueda.',
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return SingleChildScrollView(
            child: AsignacionDocenteTable(
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
                            item.docenteNombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        StatusBadge(active: item.estado),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.asignatura.codigo} · ${item.asignatura.nombre}',
                    ),
                    Text(
                      item.periodo.nombre,
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
}
