import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/layouts/admin_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/periodo_academico.dart';
import '../controllers/periodo_academico_controller.dart';
import '../widgets/periodo_academico_filters.dart';
import '../widgets/periodo_academico_form_dialog.dart';
import '../widgets/periodo_academico_table.dart';

class PeriodosAcademicosPage extends StatefulWidget {
  const PeriodosAcademicosPage({super.key});

  @override
  State<PeriodosAcademicosPage> createState() => _PeriodosAcademicosPageState();
}

class _PeriodosAcademicosPageState extends State<PeriodosAcademicosPage> {
  final _searchController = TextEditingController();
  PeriodoEstadoFiltro _estado = PeriodoEstadoFiltro.todos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PeriodoAcademicoController>().cargar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _buscar() => context.read<PeriodoAcademicoController>().cargar(
        busqueda: _searchController.text,
        estado: _estado.value,
      );

  Future<void> _limpiar() async {
    _searchController.clear();
    setState(() => _estado = PeriodoEstadoFiltro.todos);
    await context.read<PeriodoAcademicoController>().cargar(reset: true);
  }

  Future<void> _form([PeriodoAcademico? periodo]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PeriodoAcademicoController>(),
        child: PeriodoAcademicoFormDialog(periodo: periodo),
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          periodo == null
              ? 'Periodo académico registrado correctamente.'
              : 'Periodo académico actualizado correctamente.',
        ),
      ),
    );
  }

  Future<void> _toggle(PeriodoAcademico periodo) async {
    final activating = !periodo.estado;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          activating ? 'Reactivar periodo' : 'Desactivar periodo',
        ),
        content: Text(
          '¿Confirma que desea ${activating ? 'reactivar' : 'desactivar'} '
          '${periodo.nombre}?',
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
        await context.read<PeriodoAcademicoController>().cambiarEstado(periodo);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (activating
                  ? 'Periodo académico reactivado correctamente.'
                  : 'Periodo académico desactivado correctamente.'),
        ),
      ),
    );
  }

  String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PeriodoAcademicoController>();
    return AdminShell(
      selectedRoute: RouteNames.adminPeriodos,
      title: 'Periodos académicos',
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
                  title: 'Periodos académicos',
                  subtitle:
                      'Administra los periodos utilizados para organizar las actividades académicas.',
                  action: FilledButton.icon(
                    onPressed:
                        controller.state == PeriodoAcademicoViewState.loading
                            ? null
                            : () => _form(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nuevo periodo'),
                  ),
                ),
                const SizedBox(height: 22),
                PeriodoAcademicoFilters(
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

  Widget _body(PeriodoAcademicoController controller) =>
      switch (controller.state) {
        PeriodoAcademicoViewState.loading => const Card(
            child: AppLoadingState(
              message: 'Cargando periodos académicos...',
            ),
          ),
        PeriodoAcademicoViewState.empty => Card(
            child: AppEmptyState(
              icon: controller.hasFilters
                  ? Icons.search_off_rounded
                  : Icons.calendar_month_outlined,
              title: controller.hasFilters
                  ? 'No se encontraron periodos académicos con los criterios seleccionados.'
                  : 'No existen periodos académicos registrados.',
              message: controller.hasFilters
                  ? 'Cambie los filtros o limpie la búsqueda.'
                  : 'Seleccione Nuevo periodo para registrar el primero.',
            ),
          ),
        PeriodoAcademicoViewState.error => Card(
            child: AppErrorState(
              message: controller.errorMessage ??
                  'No fue posible cargar los periodos académicos.',
              onRetry: controller.cargar,
            ),
          ),
        PeriodoAcademicoViewState.data => _data(controller.items),
      };

  Widget _data(List<PeriodoAcademico> items) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 760) {
            return SingleChildScrollView(
              child: PeriodoAcademicoTable(
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
                              item.nombre,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          StatusBadge(active: item.estado),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Inicio: ${_date(item.fechaInicio)}'),
                      Text(
                        'Finalización: ${_date(item.fechaFin)}',
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
