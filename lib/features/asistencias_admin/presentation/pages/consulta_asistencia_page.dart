import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/route_names.dart';
import '../../../../shared/layouts/admin_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../asistencia/domain/entities/asistencia.dart';
import '../../domain/entities/consulta_asistencia.dart';
import '../controllers/consulta_asistencia_controller.dart';
import '../widgets/asistencia_admin_detail_dialog.dart';
import '../widgets/asistencia_admin_filters.dart';
import '../widgets/asistencia_admin_summary.dart';
import '../widgets/asistencia_admin_table.dart';

class ConsultaAsistenciaPage extends StatefulWidget {
  const ConsultaAsistenciaPage({super.key});

  @override
  State<ConsultaAsistenciaPage> createState() => _ConsultaAsistenciaPageState();
}

class _ConsultaAsistenciaPageState extends State<ConsultaAsistenciaPage> {
  final _searchController = TextEditingController();
  int? _periodoId;
  int? _asignaturaId;
  String? _docenteId;
  EstadoAsistencia? _estado;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ConsultaAsistenciaController>().cargar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _consultar() {
    final controller = context.read<ConsultaAsistenciaController>();
    return controller.cargar(controller.crearFiltro(
      busqueda: _searchController.text,
      periodoId: _periodoId,
      asignaturaId: _asignaturaId,
      docenteId: _docenteId,
      estado: _estado,
      fechaDesde: _fechaDesde,
      fechaHasta: _fechaHasta,
    ));
  }

  Future<void> _limpiar() async {
    _searchController.clear();
    setState(() {
      _periodoId = null;
      _asignaturaId = null;
      _docenteId = null;
      _estado = null;
      _fechaDesde = null;
      _fechaHasta = null;
    });
    await context.read<ConsultaAsistenciaController>().limpiarFiltros();
  }

  void _detail(ConsultaAsistencia item) => showDialog<void>(
        context: context,
        builder: (_) => AsistenciaAdminDetailDialog(item: item),
      );

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ConsultaAsistenciaController>();
    return AdminShell(
      selectedRoute: RouteNames.adminAsistencias,
      title: 'Asistencia',
      child: Padding(
        padding:
            EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  title: 'Consulta de Asistencia',
                  subtitle:
                      'Consulta los registros enviados por los docentes. Este módulo es de solo lectura.',
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      AsistenciaAdminFilters(
                        key: ValueKey(
                            '$_periodoId-$_asignaturaId-$_docenteId-$_estado-$_fechaDesde-$_fechaHasta'),
                        searchController: _searchController,
                        options: controller.options,
                        periodoId: _periodoId,
                        asignaturaId: _asignaturaId,
                        docenteId: _docenteId,
                        estado: _estado,
                        fechaDesde: _fechaDesde,
                        fechaHasta: _fechaHasta,
                        onPeriodo: (value) =>
                            setState(() => _periodoId = value),
                        onAsignatura: (value) =>
                            setState(() => _asignaturaId = value),
                        onDocente: (value) =>
                            setState(() => _docenteId = value),
                        onEstado: (value) => setState(() => _estado = value),
                        onFechaDesde: (value) =>
                            setState(() => _fechaDesde = value),
                        onFechaHasta: (value) =>
                            setState(() => _fechaHasta = value),
                        onBuscar: _consultar,
                        onLimpiar: _limpiar,
                      ),
                      const SizedBox(height: 12),
                      AsistenciaAdminSummaryCards(summary: controller.summary),
                      const SizedBox(height: 12),
                      _body(controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(ConsultaAsistenciaController controller) =>
      switch (controller.state) {
        ConsultaAsistenciaViewState.loading => const Card(
            child:
                AppLoadingState(message: 'Cargando registros de asistencia...'),
          ),
        ConsultaAsistenciaViewState.empty => Card(
            child: AppEmptyState(
              icon: Icons.fact_check_outlined,
              title: controller.hasFilters
                  ? 'No existen registros para los criterios seleccionados.'
                  : 'No se encontraron registros de asistencia.',
              message: controller.hasFilters
                  ? 'Cambie o limpie los filtros para realizar otra consulta.'
                  : 'Los registros aparecerán cuando los docentes guarden asistencia.',
            ),
          ),
        ConsultaAsistenciaViewState.error => Card(
            child: AppErrorState(
              message: controller.errorMessage ??
                  'No fue posible cargar los registros de asistencia.',
              onRetry: controller.cargar,
            ),
          ),
        ConsultaAsistenciaViewState.data => _data(controller.items),
      };

  Widget _data(List<ConsultaAsistencia> items) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 950) {
            return AsistenciaAdminTable(items: items, onDetail: _detail);
          }
          return Column(
            children: items
                .map((item) => Card(
                      child: ListTile(
                        title: Text(item.estudianteNombre),
                        subtitle: Text(
                          '${_date(item.fecha)} · ${item.asignaturaNombre}\n'
                          '${item.docenteNombre} · ${item.estado.databaseValue}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          key: ValueKey('ver_detalle_asistencia_${item.id}'),
                          onPressed: () => _detail(item),
                          tooltip: 'Ver detalle',
                          icon: const Icon(Icons.visibility_outlined),
                        ),
                      ),
                    ))
                .toList(growable: false),
          );
        },
      );

  String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}
