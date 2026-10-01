import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/layouts/admin_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/inscripcion.dart';
import '../controllers/inscripcion_controller.dart';
import '../widgets/inscripcion_filters.dart';
import '../widgets/inscripcion_form_dialog.dart';
import '../widgets/inscripcion_table.dart';

class InscripcionesPage extends StatefulWidget {
  const InscripcionesPage({super.key});

  @override
  State<InscripcionesPage> createState() => _InscripcionesPageState();
}

class _InscripcionesPageState extends State<InscripcionesPage> {
  final _searchController = TextEditingController();
  String _query = '';
  int? _estudianteId;
  int? _asignaturaId;
  int? _periodoId;
  InscripcionEstadoFiltro _estado = InscripcionEstadoFiltro.todas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<InscripcionController>().cargar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _limpiar() {
    _searchController.clear();
    setState(() {
      _query = '';
      _estudianteId = null;
      _asignaturaId = null;
      _periodoId = null;
      _estado = InscripcionEstadoFiltro.todas;
    });
  }

  Future<void> _form([Inscripcion? inscripcion]) async {
    final controller = context.read<InscripcionController>();
    if (inscripcion == null &&
        (controller.options.estudiantes.isEmpty ||
            controller.options.asignaturas.isEmpty ||
            controller.options.periodos.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe existir al menos un estudiante, una asignatura y un periodo activos.',
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
        child: InscripcionFormDialog(
          options: controller.options,
          inscripcion: inscripcion,
        ),
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          inscripcion == null
              ? 'Inscripción registrada correctamente.'
              : 'Inscripción actualizada correctamente.',
        ),
      ),
    );
  }

  Future<void> _toggle(Inscripcion inscripcion) async {
    final activating = !inscripcion.estado;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          activating ? 'Reactivar inscripción' : 'Desactivar inscripción',
        ),
        content: Text(
          '¿Confirma que desea ${activating ? 'reactivar' : 'desactivar'} la '
          'inscripción de ${inscripcion.estudianteNombre}?',
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
        await context.read<InscripcionController>().cambiarEstado(inscripcion);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (activating
                  ? 'Inscripción reactivada correctamente.'
                  : 'Inscripción desactivada correctamente.'),
        ),
      ),
    );
  }

  String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InscripcionController>();
    return AdminShell(
      selectedRoute: RouteNames.adminInscripciones,
      title: 'Inscripciones',
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
                  title: 'Inscripciones académicas',
                  subtitle:
                      'Relaciona estudiantes con asignaturas y periodos académicos.',
                  action: FilledButton.icon(
                    onPressed: controller.state == InscripcionViewState.loading
                        ? null
                        : () => _form(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nueva inscripción'),
                  ),
                ),
                const SizedBox(height: 22),
                if (controller.state == InscripcionViewState.data) ...[
                  InscripcionFilters(
                    key: ValueKey(
                      '$_estudianteId-$_asignaturaId-$_periodoId-$_estado',
                    ),
                    searchController: _searchController,
                    items: controller.items,
                    estudianteId: _estudianteId,
                    asignaturaId: _asignaturaId,
                    periodoId: _periodoId,
                    estado: _estado,
                    onEstudiante: (value) =>
                        setState(() => _estudianteId = value),
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

  Widget _body(InscripcionController controller) => switch (controller.state) {
        InscripcionViewState.loading => const Card(
            child: AppLoadingState(message: 'Cargando inscripciones...'),
          ),
        InscripcionViewState.empty => const Card(
            child: AppEmptyState(
              icon: Icons.app_registration_outlined,
              title: 'No existen inscripciones registradas.',
              message:
                  'Seleccione Nueva inscripción para registrar la primera.',
            ),
          ),
        InscripcionViewState.error => Card(
            child: AppErrorState(
              message: controller.errorMessage ??
                  'No fue posible cargar las inscripciones.',
              onRetry: controller.cargar,
            ),
          ),
        InscripcionViewState.data => _data(
            controller.filtrar(
              busqueda: _query,
              estudianteId: _estudianteId,
              asignaturaId: _asignaturaId,
              periodoId: _periodoId,
              estado: switch (_estado) {
                InscripcionEstadoFiltro.todas => null,
                InscripcionEstadoFiltro.activas => true,
                InscripcionEstadoFiltro.inactivas => false,
              },
            ),
          ),
      };

  Widget _data(List<Inscripcion> items) {
    if (items.isEmpty) {
      return const Card(
        child: AppEmptyState(
          icon: Icons.search_off_rounded,
          title:
              'No se encontraron inscripciones con los criterios seleccionados.',
          message: 'Cambie los filtros o limpie la búsqueda.',
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return SingleChildScrollView(
            child: InscripcionTable(
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
                            item.estudianteNombre,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        StatusBadge(active: item.estado),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.asignaturaCodigo} · ${item.asignaturaNombre}',
                    ),
                    Text(
                      '${item.periodoNombre} · ${_date(item.fechaInscripcion)}',
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
