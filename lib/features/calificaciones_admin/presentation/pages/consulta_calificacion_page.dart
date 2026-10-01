import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/route_names.dart';
import '../../../../shared/layouts/admin_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/consulta_calificacion.dart';
import '../controllers/consulta_calificacion_controller.dart';
import '../widgets/calificacion_admin_detail_dialog.dart';
import '../widgets/calificacion_admin_filters.dart';
import '../widgets/calificacion_admin_summary.dart';
import '../widgets/calificacion_admin_table.dart';

class ConsultaCalificacionPage extends StatefulWidget {
  const ConsultaCalificacionPage({super.key});

  @override
  State<ConsultaCalificacionPage> createState() =>
      _ConsultaCalificacionPageState();
}

class _ConsultaCalificacionPageState extends State<ConsultaCalificacionPage> {
  final _search = TextEditingController();
  final _minima = TextEditingController();
  final _maxima = TextEditingController();
  int? _periodoId;
  int? _asignaturaId;
  String? _docenteId;
  String? _tipo;
  String? _validation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ConsultaCalificacionController>().cargar(),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    _minima.dispose();
    _maxima.dispose();
    super.dispose();
  }

  double? _parse(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return normalized.isEmpty ? null : double.tryParse(normalized);
  }

  Future<void> _consultar() async {
    final min = _parse(_minima.text);
    final max = _parse(_maxima.text);
    if (_minima.text.trim().isNotEmpty && min == null ||
        _maxima.text.trim().isNotEmpty && max == null) {
      setState(() => _validation = 'Ingrese notas válidas entre 0 y 100.');
      return;
    }
    final error = await context.read<ConsultaCalificacionController>().cargar(
          CalificacionAdminFilter(
            busqueda: _search.text,
            periodoId: _periodoId,
            asignaturaId: _asignaturaId,
            docenteId: _docenteId,
            tipoEvaluacion: _tipo,
            notaMinima: min,
            notaMaxima: max,
          ),
        );
    if (mounted) setState(() => _validation = error);
  }

  Future<void> _limpiar() async {
    _search.clear();
    _minima.clear();
    _maxima.clear();
    setState(() {
      _periodoId = null;
      _asignaturaId = null;
      _docenteId = null;
      _tipo = null;
      _validation = null;
    });
    await context.read<ConsultaCalificacionController>().limpiarFiltros();
  }

  void _detail(ConsultaCalificacion item) => showDialog<void>(
        context: context,
        builder: (_) => CalificacionAdminDetailDialog(item: item),
      );

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ConsultaCalificacionController>();
    return AdminShell(
      selectedRoute: RouteNames.adminCalificaciones,
      title: 'Calificaciones',
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
                    title: 'Consulta de Calificaciones',
                    subtitle:
                        'Consulta las notas registradas por los docentes. Este módulo es de solo lectura.',
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(children: [
                      CalificacionAdminFilters(
                        key: ValueKey(
                            '$_periodoId-$_asignaturaId-$_docenteId-$_tipo'),
                        searchController: _search,
                        notaMinimaController: _minima,
                        notaMaximaController: _maxima,
                        options: controller.options,
                        periodoId: _periodoId,
                        asignaturaId: _asignaturaId,
                        docenteId: _docenteId,
                        tipoEvaluacion: _tipo,
                        onPeriodo: (value) =>
                            setState(() => _periodoId = value),
                        onAsignatura: (value) =>
                            setState(() => _asignaturaId = value),
                        onDocente: (value) =>
                            setState(() => _docenteId = value),
                        onTipo: (value) => setState(() => _tipo = value),
                        onConsultar: _consultar,
                        onLimpiar: _limpiar,
                        validationMessage: _validation,
                      ),
                      const SizedBox(height: 12),
                      CalificacionAdminSummaryCards(
                          summary: controller.summary),
                      const SizedBox(height: 12),
                      _body(controller),
                    ]),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _body(ConsultaCalificacionController controller) =>
      switch (controller.state) {
        ConsultaCalificacionViewState.loading => const Card(
            child: AppLoadingState(message: 'Cargando calificaciones...')),
        ConsultaCalificacionViewState.empty => Card(
              child: AppEmptyState(
            icon: Icons.grading_outlined,
            title: controller.hasFilters
                ? 'No existen calificaciones para los criterios seleccionados.'
                : 'No se encontraron calificaciones.',
            message: controller.hasFilters
                ? 'Cambie o limpie los filtros para realizar otra consulta.'
                : 'Las calificaciones aparecerán cuando los docentes las registren.',
          )),
        ConsultaCalificacionViewState.error => Card(
              child: AppErrorState(
            message: controller.errorMessage ??
                'No fue posible cargar las calificaciones.',
            onRetry: controller.cargar,
          )),
        ConsultaCalificacionViewState.data => _data(controller.items),
      };

  Widget _data(List<ConsultaCalificacion> items) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 950) {
            return CalificacionAdminTable(items: items, onDetail: _detail);
          }
          return Column(
            children: items
                .map((item) => Card(
                      child: ListTile(
                        title: Text(item.estudianteNombre),
                        subtitle: Text(
                          '${item.asignaturaNombre} · ${item.tipoEvaluacion}\n'
                          '${item.docenteNombre} · Nota: ${_nota(item.nota)}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          key: ValueKey('ver_detalle_calificacion_${item.id}'),
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

  String _nota(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}
