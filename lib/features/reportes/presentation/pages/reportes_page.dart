import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/layouts/admin_shell.dart';
import '../../../../routes/route_names.dart';
import '../../../calificaciones/domain/entities/calificacion.dart';
import '../../domain/entities/reporte_academico.dart';
import '../controllers/reportes_controller.dart';
import '../services/csv_downloader.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});
  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ReportesController>().cargar());
  }

  @override
  Widget build(BuildContext context) => AdminShell(
        selectedRoute: RouteNames.adminReportes,
        title: 'Reportes Académicos',
        child: Consumer<ReportesController>(builder: (context, controller, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Reportes Académicos',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Información consolidada de solo lectura.'),
              const SizedBox(height: 20),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final type in TipoReporteAcademico.values)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: controller.tipo == type,
                    onSelected: controller.state == ReportesViewState.loading
                        ? null
                        : (_) => controller.seleccionar(type),
                  ),
              ]),
              const SizedBox(height: 16),
              _Filters(controller: controller),
              const SizedBox(height: 16),
              if (controller.state == ReportesViewState.loading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator()))
              else if (controller.state == ReportesViewState.error)
                _Message(
                    controller.errorMessage ??
                        'No fue posible generar el reporte.',
                    retry: controller.cargar)
              else if (controller.state == ReportesViewState.empty)
                _Message(controller.hasFilters
                    ? 'No se encontraron resultados para los criterios seleccionados.'
                    : 'No existen datos para generar este reporte.')
              else ...[
                _Summary(controller: controller),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Exportar CSV'),
                    onPressed: () async {
                      final export = controller.exportar();
                      try {
                        await downloadCsv(export.fileName, export.content);
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())));
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _Results(controller: controller),
              ],
            ],
          );
        }),
      );
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});
  final ReportesController controller;

  @override
  Widget build(BuildContext context) {
    final f = controller.filter;
    final type = controller.tipo;
    final student = type != TipoReporteAcademico.asignaciones;
    final teacher = type != TipoReporteAcademico.inscripciones;
    final state = type == TipoReporteAcademico.inscripciones ||
        type == TipoReporteAcademico.asignaciones;
    final dates = type == TipoReporteAcademico.asistencia;
    void apply(
        {int? period,
        int? subject,
        int? studentId,
        String? teacherId,
        bool? active,
        DateTime? from,
        DateTime? to}) {
      controller.cargar(ReporteFilter(
        periodoId: period ?? f.periodoId,
        asignaturaId: subject ?? f.asignaturaId,
        estudianteId: studentId ?? f.estudianteId,
        docenteId: teacherId ?? f.docenteId,
        estado: active ?? f.estado,
        fechaDesde: from ?? f.fechaDesde,
        fechaHasta: to ?? f.fechaHasta,
      ));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Drop<int>(
                  label: 'Periodo',
                  value: f.periodoId,
                  options: controller.options.periodos,
                  onChanged: (v) => controller.cargar(ReporteFilter(
                      periodoId: v,
                      asignaturaId: f.asignaturaId,
                      estudianteId: f.estudianteId,
                      docenteId: f.docenteId,
                      estado: f.estado,
                      fechaDesde: f.fechaDesde,
                      fechaHasta: f.fechaHasta))),
              _Drop<int>(
                  label: 'Asignatura',
                  value: f.asignaturaId,
                  options: controller.options.asignaturas,
                  onChanged: (v) => controller.cargar(ReporteFilter(
                      periodoId: f.periodoId,
                      asignaturaId: v,
                      estudianteId: f.estudianteId,
                      docenteId: f.docenteId,
                      estado: f.estado,
                      fechaDesde: f.fechaDesde,
                      fechaHasta: f.fechaHasta))),
              if (student)
                _Drop<int>(
                    label: 'Estudiante',
                    value: f.estudianteId,
                    options: controller.options.estudiantes,
                    onChanged: (v) => controller.cargar(ReporteFilter(
                        periodoId: f.periodoId,
                        asignaturaId: f.asignaturaId,
                        estudianteId: v,
                        docenteId: f.docenteId,
                        estado: f.estado,
                        fechaDesde: f.fechaDesde,
                        fechaHasta: f.fechaHasta))),
              if (teacher)
                _Drop<String>(
                    label: 'Docente',
                    value: f.docenteId,
                    options: controller.options.docentes,
                    onChanged: (v) => controller.cargar(ReporteFilter(
                        periodoId: f.periodoId,
                        asignaturaId: f.asignaturaId,
                        estudianteId: f.estudianteId,
                        docenteId: v,
                        estado: f.estado,
                        fechaDesde: f.fechaDesde,
                        fechaHasta: f.fechaHasta))),
              if (state)
                SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<bool?>(
                        initialValue: f.estado,
                        decoration: const InputDecoration(
                            labelText: 'Estado', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(value: true, child: Text('Activos')),
                          DropdownMenuItem(
                              value: false, child: Text('Inactivos'))
                        ],
                        onChanged: (v) => controller.cargar(ReporteFilter(
                            periodoId: f.periodoId,
                            asignaturaId: f.asignaturaId,
                            estudianteId: f.estudianteId,
                            docenteId: f.docenteId,
                            estado: v)))),
              if (dates)
                _DateButton(
                    label: 'Desde',
                    value: f.fechaDesde,
                    onChanged: (v) => apply(from: v)),
              if (dates)
                _DateButton(
                    label: 'Hasta',
                    value: f.fechaHasta,
                    onChanged: (v) => apply(to: v)),
              TextButton.icon(
                  onPressed:
                      controller.hasFilters ? controller.limpiarFiltros : null,
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Limpiar filtros')),
            ]),
      ),
    );
  }
}

class _Drop<T> extends StatelessWidget {
  const _Drop(
      {required this.label,
      required this.value,
      required this.options,
      required this.onChanged});
  final String label;
  final T? value;
  final List<ReporteOption<T>> options;
  final ValueChanged<T?> onChanged;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 220,
      child: DropdownButtonFormField<T?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        items: [
          DropdownMenuItem<T?>(value: null, child: const Text('Todos')),
          ...options.map((e) => DropdownMenuItem<T?>(
              value: e.id,
              child: Text(e.label, overflow: TextOverflow.ellipsis)))
        ],
        onChanged: onChanged,
      ));
}

class _DateButton extends StatelessWidget {
  const _DateButton(
      {required this.label, required this.value, required this.onChanged});
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        icon: const Icon(Icons.calendar_today_outlined),
        label: Text(value == null
            ? label
            : '$label: ${value!.day}/${value!.month}/${value!.year}'),
        onPressed: () async {
          final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100));
          if (picked != null) onChanged(picked);
        },
      );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.controller});
  final ReportesController controller;
  @override
  Widget build(BuildContext context) {
    late final List<(String, String)> values;
    if (controller.tipo == TipoReporteAcademico.calificaciones) {
      final s = controller.calificacionSummary;
      values = [
        ('Evaluados', '${s.total}'),
        ('Reprobados', '${s.reprobados}'),
        ('Aprobados', '${s.aprobados}'),
        ('Excelentes', '${s.excelentes}'),
        ('Promedio general', s.promedioGeneral?.toStringAsFixed(2) ?? '-')
      ];
    } else if (controller.tipo == TipoReporteAcademico.asistencia) {
      final rows = controller.items.cast<ReporteAsistenciaItem>();
      values = [
        ('Estudiantes', '${rows.length}'),
        ('Presentes', '${rows.fold<int>(0, (a, b) => a + b.presentes)}'),
        ('Ausentes', '${rows.fold<int>(0, (a, b) => a + b.ausentes)}'),
        ('Licencias', '${rows.fold<int>(0, (a, b) => a + b.licencias)}')
      ];
    } else {
      final s = controller.estadoSummary;
      values = [
        ('Total', '${s.total}'),
        ('Activos', '${s.activos}'),
        ('Inactivos', '${s.inactivos}')
      ];
    }
    return Wrap(spacing: 10, runSpacing: 10, children: [
      for (final v in values)
        Card(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(children: [
                  Text(v.$1),
                  Text(v.$2,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold))
                ])))
    ]);
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.controller});
  final ReportesController controller;
  @override
  Widget build(BuildContext context) {
    final (columns, rows) = switch (controller.tipo) {
      TipoReporteAcademico.inscripciones =>
        _inscripciones(controller.items.cast<ReporteInscripcionItem>()),
      TipoReporteAcademico.asistencia =>
        _asistencia(controller.items.cast<ReporteAsistenciaItem>()),
      TipoReporteAcademico.calificaciones =>
        _calificaciones(controller.items.cast<ReporteCalificacionItem>()),
      TipoReporteAcademico.asignaciones =>
        _asignaciones(controller.items.cast<ReporteAsignacionItem>()),
    };
    return Card(
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
                columns:
                    columns.map((e) => DataColumn(label: Text(e))).toList(),
                rows: rows
                    .map((r) => DataRow(
                        cells: r.map((e) => DataCell(Text(e))).toList()))
                    .toList())));
  }

  static (List<String>, List<List<String>>) _inscripciones(
          List<ReporteInscripcionItem> items) =>
      (
        [
          'Estudiante',
          'Código',
          'CI',
          'Asignatura',
          'Periodo',
          'Fecha',
          'Estado'
        ],
        [
          for (final e in items)
            [
              e.estudiante,
              e.codigo,
              e.ci,
              e.asignatura,
              e.periodo,
              _date(e.fecha),
              e.estado ? 'ACTIVA' : 'INACTIVA'
            ]
        ]
      );
  static (List<String>, List<List<String>>) _asistencia(
          List<ReporteAsistenciaItem> items) =>
      (
        [
          'Estudiante',
          'Asignatura',
          'Periodo',
          'Docente',
          'Presentes',
          'Ausentes',
          'Licencias',
          'Total',
          '%'
        ],
        [
          for (final e in items)
            [
              e.estudiante,
              e.asignatura,
              e.periodo,
              e.docente,
              '${e.presentes}',
              '${e.ausentes}',
              '${e.licencias}',
              '${e.total}',
              '${e.porcentaje.toStringAsFixed(2)}%'
            ]
        ]
      );
  static (List<String>, List<List<String>>) _calificaciones(
          List<ReporteCalificacionItem> items) =>
      (
        [
          'Estudiante',
          'Asignatura',
          'Periodo',
          'Docente',
          'Evaluaciones',
          'Promedio',
          'Mínima',
          'Máxima',
          'Resultado académico'
        ],
        [
          for (final e in items)
            [
              e.estudiante,
              e.asignatura,
              e.periodo,
              e.docente,
              '${e.evaluaciones}',
              e.promedio.toStringAsFixed(2),
              e.minima.toStringAsFixed(2),
              e.maxima.toStringAsFixed(2),
              e.resultado.label
            ]
        ]
      );
  static (List<String>, List<List<String>>) _asignaciones(
          List<ReporteAsignacionItem> items) =>
      (
        ['Docente', 'Asignatura', 'Periodo', 'Fecha', 'Estado'],
        [
          for (final e in items)
            [
              e.docente,
              e.asignatura,
              e.periodo,
              _date(e.fecha),
              e.estado ? 'ACTIVA' : 'INACTIVA'
            ]
        ]
      );
  static String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.retry});
  final String text;
  final Future<void> Function()? retry;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(children: [
            const Icon(Icons.inbox_outlined, size: 48),
            const SizedBox(height: 12),
            Text(text),
            if (retry != null)
              TextButton(onPressed: retry, child: const Text('Reintentar'))
          ])));
}
