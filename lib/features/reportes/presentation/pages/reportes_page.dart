import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/route_names.dart';
import '../../../../shared/layouts/admin_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/pagination_bar.dart';
import '../../../../shared/widgets/responsive_table.dart';
import '../../../calificaciones/domain/entities/calificacion.dart';
import '../../domain/entities/reporte_academico.dart';
import '../controllers/reportes_controller.dart';
import '../services/pdf_downloader.dart';
import '../services/report_pdf_service.dart';

enum _ReportKind { asignatura, estudiante, asistencia, calificaciones, general }

extension on _ReportKind {
  String get label => switch (this) {
        _ReportKind.asignatura => 'Reporte por asignatura',
        _ReportKind.estudiante => 'Reporte por estudiante',
        _ReportKind.asistencia => 'Reporte de asistencia',
        _ReportKind.calificaciones => 'Reporte de calificaciones',
        _ReportKind.general => 'Reporte general por periodo académico',
      };
  IconData get icon => switch (this) {
        _ReportKind.asignatura => Icons.menu_book_outlined,
        _ReportKind.estudiante => Icons.person_search_outlined,
        _ReportKind.asistencia => Icons.fact_check_outlined,
        _ReportKind.calificaciones => Icons.grading_outlined,
        _ReportKind.general => Icons.assessment_outlined,
      };
}

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});
  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  static const _institution = 'SEMINARIO DE FORMACIÓN MINISTERIAL TARIJA';
  _ReportKind? _kind;
  int? _periodoId, _asignaturaId, _estudianteId;
  String? _docenteId;
  bool? _estado;
  DateTime? _desde, _hasta;
  bool _previewReady = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ReportesController>().cargar());
  }

  void _invalidate() => setState(() {
        _previewReady = false;
        _currentPage = 1;
      });

  void _selectKind(_ReportKind value) => setState(() {
        _kind = value;
        _periodoId = _asignaturaId = _estudianteId = null;
        _docenteId = null;
        _estado = null;
        _desde = _hasta = null;
        _previewReady = false;
        _currentPage = 1;
      });

  String? _validationMessage() {
    if (_kind == null) return 'Seleccione un tipo de reporte para continuar.';
    if (_periodoId == null) return 'Seleccione un periodo académico.';
    if ((_kind == _ReportKind.asignatura ||
            _kind == _ReportKind.asistencia ||
            _kind == _ReportKind.calificaciones) &&
        _asignaturaId == null) {
      return 'Seleccione una asignatura para continuar.';
    }
    if (_kind == _ReportKind.estudiante && _estudianteId == null) {
      return 'Seleccione un estudiante para continuar.';
    }
    return null;
  }

  Future<void> _preview(ReportesController controller) async {
    final message = _validationMessage();
    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    controller.tipo = switch (_kind!) {
      _ReportKind.asignatura ||
      _ReportKind.estudiante =>
        TipoReporteAcademico.inscripciones,
      _ReportKind.asistencia => TipoReporteAcademico.asistencia,
      _ReportKind.calificaciones => TipoReporteAcademico.calificaciones,
      _ReportKind.general => TipoReporteAcademico.asignaciones,
    };
    await controller.cargar(ReporteFilter(
      periodoId: _periodoId,
      asignaturaId: _asignaturaId,
      estudianteId: _estudianteId,
      docenteId: _docenteId,
      estado: _estado,
      fechaDesde: _desde,
      fechaHasta: _hasta,
    ));
    if (!mounted) return;
    setState(() {
      _previewReady = controller.state == ReportesViewState.data;
      _currentPage = 1;
    });
  }

  void _clear(ReportesController controller) {
    setState(() {
      _periodoId = _asignaturaId = _estudianteId = null;
      _docenteId = null;
      _estado = null;
      _desde = _hasta = null;
      _previewReady = false;
      _currentPage = 1;
    });
    controller.limpiarFiltros();
  }

  @override
  Widget build(BuildContext context) => AdminShell(
        selectedRoute: RouteNames.adminReportes,
        title: 'Reportes Académicos',
        child: Consumer<ReportesController>(builder: (context, controller, _) {
          return ListView(
            padding: EdgeInsets.all(
                MediaQuery.sizeOf(context).width < 600 ? 16 : 28),
            children: [
              Text('Generación de reportes',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                  'Seleccione el tipo de reporte, complete los filtros y genere una vista previa antes de imprimir.'),
              const SizedBox(height: 20),
              _TypeSelector(selected: _kind, onSelected: _selectKind),
              if (_kind != null) ...[
                const SizedBox(height: 16),
                _FilterPanel(
                  key: ValueKey(
                      '$_kind-$_periodoId-$_asignaturaId-$_estudianteId-$_docenteId-$_estado-$_desde-$_hasta'),
                  kind: _kind!,
                  options: controller.options,
                  periodoId: _periodoId,
                  asignaturaId: _asignaturaId,
                  estudianteId: _estudianteId,
                  docenteId: _docenteId,
                  estado: _estado,
                  desde: _desde,
                  hasta: _hasta,
                  onPeriodo: (v) {
                    _periodoId = v;
                    _invalidate();
                  },
                  onAsignatura: (v) {
                    _asignaturaId = v;
                    _invalidate();
                  },
                  onEstudiante: (v) {
                    _estudianteId = v;
                    _invalidate();
                  },
                  onDocente: (v) {
                    _docenteId = v;
                    _invalidate();
                  },
                  onEstado: (v) {
                    _estado = v;
                    _invalidate();
                  },
                  onDesde: (v) {
                    _desde = v;
                    _invalidate();
                  },
                  onHasta: (v) {
                    _hasta = v;
                    _invalidate();
                  },
                  onPreview: controller.state == ReportesViewState.loading
                      ? null
                      : () => _preview(controller),
                  onClear: () => _clear(controller),
                ),
              ],
              const SizedBox(height: 20),
              if (controller.state == ReportesViewState.loading)
                const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()))
              else if (controller.state == ReportesViewState.error)
                Card(
                    child: AppErrorState(
                        message: controller.errorMessage ??
                            'No fue posible generar el reporte.',
                        onRetry: () => _preview(controller)))
              else if (_previewReady)
                _Preview(
                  institution: _institution,
                  kind: _kind!,
                  controller: controller,
                  metadata: _metadata(controller.options),
                  currentPage: _currentPage,
                  onPageChanged: (v) => setState(() => _currentPage = v),
                  onPrint: () => _print(controller),
                  onPdf: () => _exportPdf(controller),
                )
              else if (_kind != null)
                const Card(
                    child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                            child: Text(
                                'Complete los filtros y seleccione “Vista previa”.')))),
            ],
          );
        }),
      );

  Map<String, String> _metadata(ReporteOptions options) {
    String label<T>(List<ReporteOption<T>> values, T? id) => id == null
        ? ''
        : values.where((e) => e.id == id).map((e) => e.label).firstOrNull ?? '';
    return {
      'Periodo académico': label(options.periodos, _periodoId),
      if (_asignaturaId != null)
        'Asignatura': label(options.asignaturas, _asignaturaId),
      if (_estudianteId != null)
        'Estudiante': label(options.estudiantes, _estudianteId),
      if (_docenteId != null) 'Docente': label(options.docentes, _docenteId),
      'Fecha de generación': _date(DateTime.now()),
    };
  }

  Future<Uint8List> _pdf(ReportesController controller) {
    final data = _data(controller);
    return generateReportPdf(
      institution: _institution,
      title: _kind!.label,
      metadata: _metadata(controller.options),
      columns: data.columns,
      rows: data.rows,
      summary: data.summary,
    );
  }

  Future<void> _print(ReportesController controller) async {
    try {
      await printReportPdf(await _pdf(controller));
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _exportPdf(ReportesController controller) async {
    try {
      final name =
          'reporte_${_kind!.name}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await downloadPdf(name, await _pdf(controller));
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onSelected});
  final _ReportKind? selected;
  final ValueChanged<_ReportKind> onSelected;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('1. Tipo de reporte',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LayoutBuilder(
                builder: (context, c) => c.maxWidth < 700
                    ? DropdownButtonFormField<_ReportKind>(
                        initialValue: selected,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Reporte'),
                        items: [
                          for (final v in _ReportKind.values)
                            DropdownMenuItem(value: v, child: Text(v.label))
                        ],
                        onChanged: (v) {
                          if (v != null) onSelected(v);
                        })
                    : Wrap(spacing: 10, runSpacing: 10, children: [
                        for (final v in _ReportKind.values)
                          ChoiceChip(
                              avatar: Icon(v.icon, size: 18),
                              label: Text(v.label),
                              selected: selected == v,
                              onSelected: (_) => onSelected(v))
                      ])),
          ])));
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel(
      {super.key,
      required this.kind,
      required this.options,
      required this.periodoId,
      required this.asignaturaId,
      required this.estudianteId,
      required this.docenteId,
      required this.estado,
      required this.desde,
      required this.hasta,
      required this.onPeriodo,
      required this.onAsignatura,
      required this.onEstudiante,
      required this.onDocente,
      required this.onEstado,
      required this.onDesde,
      required this.onHasta,
      required this.onPreview,
      required this.onClear});
  final _ReportKind kind;
  final ReporteOptions options;
  final int? periodoId, asignaturaId, estudianteId;
  final String? docenteId;
  final bool? estado;
  final DateTime? desde, hasta;
  final ValueChanged<int?> onPeriodo, onAsignatura, onEstudiante;
  final ValueChanged<String?> onDocente;
  final ValueChanged<bool?> onEstado;
  final ValueChanged<DateTime?> onDesde, onHasta;
  final VoidCallback? onPreview;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('2. Filtros',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, c) {
              final width = c.maxWidth < 600 ? c.maxWidth : 260.0;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                _drop('Periodo académico *', periodoId, options.periodos,
                    onPeriodo, width),
                if (kind == _ReportKind.asignatura ||
                    kind == _ReportKind.asistencia ||
                    kind == _ReportKind.calificaciones)
                  _drop('Asignatura *', asignaturaId, options.asignaturas,
                      onAsignatura, width),
                if (kind == _ReportKind.estudiante)
                  _drop('Estudiante *', estudianteId, options.estudiantes,
                      onEstudiante, width),
                if (kind == _ReportKind.asistencia ||
                    kind == _ReportKind.calificaciones)
                  _drop('Docente (opcional)', docenteId, options.docentes,
                      onDocente, width),
                if (kind == _ReportKind.asignatura ||
                    kind == _ReportKind.estudiante ||
                    kind == _ReportKind.general)
                  SizedBox(
                      width: width,
                      child: DropdownButtonFormField<bool?>(
                          initialValue: estado,
                          decoration: const InputDecoration(
                              labelText: 'Estado (opcional)'),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Todos')),
                            DropdownMenuItem(
                                value: true, child: Text('Activos')),
                            DropdownMenuItem(
                                value: false, child: Text('Inactivos'))
                          ],
                          onChanged: onEstado)),
                if (kind == _ReportKind.asistencia)
                  _dateButton(
                      context, 'Desde (opcional)', desde, onDesde, width),
                if (kind == _ReportKind.asistencia)
                  _dateButton(
                      context, 'Hasta (opcional)', hasta, onHasta, width),
              ]);
            }),
            const SizedBox(height: 18),
            Wrap(spacing: 10, runSpacing: 10, children: [
              FilledButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.preview_outlined),
                  label: const Text('Vista previa')),
              OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Limpiar filtros'))
            ]),
          ])));
  Widget _drop<T>(String label, T? value, List<ReporteOption<T>> options,
          ValueChanged<T?> changed, double width) =>
      SizedBox(
          width: width,
          child: DropdownButtonFormField<T>(
              initialValue: value,
              isExpanded: true,
              decoration: InputDecoration(labelText: label),
              items: [
                for (final e in options)
                  DropdownMenuItem(
                      value: e.id,
                      child: Text(e.label, overflow: TextOverflow.ellipsis))
              ],
              onChanged: changed));
  Widget _dateButton(BuildContext context, String label, DateTime? value,
          ValueChanged<DateTime?> changed, double width) =>
      SizedBox(
          width: width,
          child: OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(value == null
                  ? label
                  : '${value.day}/${value.month}/${value.year}'),
              onPressed: () async {
                final picked = await showDatePicker(
                    context: context,
                    initialDate: value ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100));
                if (picked != null) changed(picked);
              }));
}

class _Preview extends StatelessWidget {
  const _Preview(
      {required this.institution,
      required this.kind,
      required this.controller,
      required this.metadata,
      required this.currentPage,
      required this.onPageChanged,
      required this.onPrint,
      required this.onPdf});
  final String institution;
  final _ReportKind kind;
  final ReportesController controller;
  final Map<String, String> metadata;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPrint, onPdf;
  @override
  Widget build(BuildContext context) {
    final data = _data(controller);
    const pageSize = 10;
    final pages = (data.rows.length / pageSize).ceil();
    final page = currentPage.clamp(1, pages);
    final rows = data.rows.skip((page - 1) * pageSize).take(pageSize).toList();
    return Card(
        child: Padding(
            padding: EdgeInsets.all(
                MediaQuery.sizeOf(context).width < 600 ? 12 : 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text('Vista previa',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold))),
                    Wrap(spacing: 8, children: [
                      OutlinedButton.icon(
                          onPressed: onPrint,
                          icon: const Icon(Icons.print_outlined),
                          label: const Text('Imprimir')),
                      FilledButton.tonalIcon(
                          onPressed: onPdf,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Exportar PDF'))
                    ])
                  ]),
                  const Divider(height: 32),
                  Text(institution,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(kind.label.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 18),
                  Wrap(spacing: 24, runSpacing: 8, children: [
                    for (final e in metadata.entries)
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: '${e.key}: ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: e.value)
                      ]))
                  ]),
                  const SizedBox(height: 18),
                  ResponsiveTable(
                      minimumWidth: data.columns.length > 7 ? 1250 : 950,
                      columns: [
                        for (final c in data.columns)
                          ResponsiveTableColumn(c,
                              flex: c == 'Estudiante' ||
                                      c == 'Asignatura' ||
                                      c == 'Docente'
                                  ? 1.8
                                  : 1.1)
                      ],
                      rows: [
                        for (final row in rows)
                          [for (final value in row) Text(value)]
                      ]),
                  if (pages > 1) ...[
                    const SizedBox(height: 14),
                    PaginationBar(
                        currentPage: page,
                        totalPages: pages,
                        onPageChanged: onPageChanged)
                  ],
                  const SizedBox(height: 14),
                  Text(data.summary,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ])));
  }
}

class _ReportData {
  const _ReportData(this.columns, this.rows, this.summary);
  final List<String> columns;
  final List<List<String>> rows;
  final String summary;
}

_ReportData _data(ReportesController c) => switch (c.tipo) {
      TipoReporteAcademico.inscripciones => _ReportData(const [
          'Estudiante',
          'Código',
          'CI',
          'Asignatura',
          'Periodo',
          'Fecha',
          'Estado'
        ], [
          for (final e in c.items.cast<ReporteInscripcionItem>())
            [
              e.estudiante,
              e.codigo,
              e.ci,
              e.asignatura,
              e.periodo,
              _d(e.fecha),
              e.estado ? 'ACTIVA' : 'INACTIVA'
            ]
        ], 'Total de registros: ${c.items.length}'),
      TipoReporteAcademico.asistencia => _ReportData(const [
          'Estudiante',
          'Asignatura',
          'Periodo',
          'Docente',
          'Presentes',
          'Ausentes',
          'Licencias',
          'Total',
          '%'
        ], [
          for (final e in c.items.cast<ReporteAsistenciaItem>())
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
        ], 'Total de estudiantes: ${c.items.length}'),
      TipoReporteAcademico.calificaciones => _ReportData(const [
          'Estudiante',
          'Asignatura',
          'Periodo',
          'Docente',
          'Evaluaciones',
          'Promedio',
          'Mínima',
          'Máxima',
          'Resultado'
        ], [
          for (final e in c.items.cast<ReporteCalificacionItem>())
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
        ], 'Total de estudiantes evaluados: ${c.calificacionSummary.total}'),
      TipoReporteAcademico.asignaciones => _ReportData(const [
          'Docente',
          'Asignatura',
          'Periodo',
          'Fecha',
          'Estado'
        ], [
          for (final e in c.items.cast<ReporteAsignacionItem>())
            [
              e.docente,
              e.asignatura,
              e.periodo,
              _d(e.fecha),
              e.estado ? 'ACTIVA' : 'INACTIVA'
            ]
        ], 'Total de registros: ${c.items.length}'),
    };

String _d(DateTime v) =>
    '${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}/${v.year}';
