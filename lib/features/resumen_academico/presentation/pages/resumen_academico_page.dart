import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/paginated_view.dart';
import '../../../../shared/widgets/responsive_table.dart';
import '../../../asignaciones_docente/domain/entities/asignacion_docente.dart';
import '../../domain/entities/resumen_academico.dart';
import '../controllers/resumen_academico_controller.dart';

class ResumenAcademicoPage extends StatefulWidget {
  const ResumenAcademicoPage({super.key});

  @override
  State<ResumenAcademicoPage> createState() => _ResumenAcademicoPageState();
}

class _ResumenAcademicoPageState extends State<ResumenAcademicoPage> {
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ResumenAcademicoController>().cargar(),
    );
  }

  Future<void> _recargar(ResumenAcademicoController controller) async {
    setState(() => _currentPage = 1);
    await controller.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResumenAcademicoController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen académico')),
      body: SafeArea(
        child: switch (controller.state) {
          ResumenAcademicoState.loading => const AppLoadingState(
              message: 'Cargando resumen académico...',
            ),
          ResumenAcademicoState.error => AppErrorState(
              message: controller.errorMessage ??
                  'No fue posible cargar el resumen académico.',
              onRetry: () => _recargar(controller),
            ),
          ResumenAcademicoState.empty => _EmptyContent(
              resumen: controller.resumen!,
              onRefresh: () => _recargar(controller),
              onAsistencia: () => _abrirAsistencia(controller.asignacion!),
              onCalificaciones: () =>
                  _abrirCalificaciones(controller.asignacion!),
            ),
          ResumenAcademicoState.data =>
            PaginatedView<ResumenAcademicoEstudiante>(
              items: controller.resumen!.estudiantes,
              currentPage: _currentPage,
              onPageChanged: (page) => setState(() => _currentPage = page),
              builder: (context, estudiantes) => _DataContent(
                resumen: controller.resumen!,
                estudiantes: estudiantes,
                onRefresh: () => _recargar(controller),
                onAsistencia: () => _abrirAsistencia(controller.asignacion!),
                onCalificaciones: () =>
                    _abrirCalificaciones(controller.asignacion!),
              ),
            ),
        },
      ),
    );
  }

  void _abrirAsistencia(AsignacionDocente asignacion) {
    Navigator.pushNamed(
      context,
      RouteNames.docenteAsistencia(asignacion.id),
      arguments: asignacion,
    );
  }

  void _abrirCalificaciones(AsignacionDocente asignacion) {
    Navigator.pushNamed(
      context,
      RouteNames.docenteCalificaciones(asignacion.id),
      arguments: asignacion,
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent({
    required this.resumen,
    required this.onRefresh,
    required this.onAsistencia,
    required this.onCalificaciones,
  });

  final ResumenAcademico resumen;
  final Future<void> Function() onRefresh;
  final VoidCallback onAsistencia;
  final VoidCallback onCalificaciones;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _Overview(
              resumen: resumen,
              onAsistencia: onAsistencia,
              onCalificaciones: onCalificaciones,
            ),
            const SizedBox(height: 28),
            const SizedBox(
              height: 340,
              child: AppEmptyState(
                icon: Icons.groups_outlined,
                title: 'No hay estudiantes inscritos.',
                message:
                    'No existen inscripciones activas para esta asignatura.',
              ),
            ),
          ],
        ),
      );
}

class _DataContent extends StatelessWidget {
  const _DataContent({
    required this.resumen,
    required this.estudiantes,
    required this.onRefresh,
    required this.onAsistencia,
    required this.onCalificaciones,
  });

  final ResumenAcademico resumen;
  final List<ResumenAcademicoEstudiante> estudiantes;
  final Future<void> Function() onRefresh;
  final VoidCallback onAsistencia;
  final VoidCallback onCalificaciones;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _Overview(
              resumen: resumen,
              onAsistencia: onAsistencia,
              onCalificaciones: onCalificaciones,
            ),
            const SizedBox(height: 24),
            Text(
              'Estudiantes inscritos',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'La asistencia corresponde a presentes sobre el total de registros existentes.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth >= 760
                  ? _StudentTable(estudiantes: estudiantes)
                  : _StudentCards(estudiantes: estudiantes),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.resumen,
    required this.onAsistencia,
    required this.onCalificaciones,
  });

  final ResumenAcademico resumen;
  final VoidCallback onAsistencia;
  final VoidCallback onCalificaciones;

  @override
  Widget build(BuildContext context) {
    final asignacion = resumen.asignacion;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.menu_book_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asignacion.asignatura.nombre,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${asignacion.asignatura.codigo} · ${asignacion.periodo.nombre}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _AssignmentStatusIcon(
                          active: asignacion.estado,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _ActionButtons(
                      onAsistencia: onAsistencia,
                      onCalificaciones: onCalificaciones,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 4
                    : constraints.maxWidth >= 540
                        ? 2
                        : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      width: width,
                      icon: Icons.groups_outlined,
                      label: 'Inscritos',
                      value: '${resumen.totalInscritos}',
                    ),
                    _MetricCard(
                      width: width,
                      icon: Icons.grading_outlined,
                      label: 'Promedio de calificaciones',
                      value: resumen.promedioCalificaciones == null
                          ? 'Sin calificaciones'
                          : '${_number(resumen.promedioCalificaciones!)} / 100',
                    ),
                    _MetricCard(
                      width: width,
                      icon: Icons.percent_rounded,
                      label: 'Asistencia general',
                      value: resumen.porcentajeAsistencia == null
                          ? 'Sin registros'
                          : '${_number(resumen.porcentajeAsistencia!)} %',
                    ),
                    _MetricCard(
                      width: width,
                      icon: Icons.fact_check_outlined,
                      label: 'Registros de asistencia',
                      value: resumen.totalAsistencias == 0
                          ? 'Sin registros'
                          : '${resumen.presentes} P · ${resumen.ausentes} A · ${resumen.licencias} L',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onAsistencia,
    required this.onCalificaciones,
  });

  final VoidCallback onAsistencia;
  final VoidCallback onCalificaciones;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final asistencia = FilledButton.icon(
            onPressed: onAsistencia,
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Registrar asistencia'),
          );
          final calificaciones = OutlinedButton.icon(
            onPressed: onCalificaciones,
            icon: const Icon(Icons.grading_outlined),
            label: const Text('Registrar calificaciones'),
          );
          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                asistencia,
                const SizedBox(height: 8),
                calificaciones,
              ],
            );
          }
          return Row(
            children: [
              asistencia,
              const SizedBox(width: 10),
              calificaciones,
            ],
          );
        },
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _StudentCards extends StatelessWidget {
  const _StudentCards({required this.estudiantes});

  final List<ResumenAcademicoEstudiante> estudiantes;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < estudiantes.length; index++) ...[
            _StudentCard(item: estudiantes[index]),
            if (index != estudiantes.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.item});

  final ResumenAcademicoEstudiante item;

  @override
  Widget build(BuildContext context) => Card(
        key: Key('resumen_estudiante_${item.estudiante.estudianteId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.estudiante.nombreCompleto,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                item.estudiante.codigo?.isNotEmpty == true
                    ? item.estudiante.codigo!
                    : 'Sin código',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Chip(label: Text('Inscripción activa')),
                  _AttendanceChip(item: item),
                  _GradeChip(item: item),
                ],
              ),
              if (item.calificaciones.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Calificaciones registradas',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 5),
                _GradeDetails(item: item),
              ],
            ],
          ),
        ),
      );
}

class _AssignmentStatusIcon extends StatelessWidget {
  const _AssignmentStatusIcon({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final label = active ? 'Asignación activa' : 'Asignación inactiva';
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: Icon(
          active ? Icons.check_circle_rounded : Icons.cancel_rounded,
          key: const Key('assignment_status_icon'),
          color: color,
          size: 26,
        ),
      ),
    );
  }
}

class _StudentTable extends StatelessWidget {
  const _StudentTable({required this.estudiantes});

  final List<ResumenAcademicoEstudiante> estudiantes;

  @override
  Widget build(BuildContext context) => ResponsiveTable(
        minimumWidth: 820,
        columns: const [
          ResponsiveTableColumn('Estudiante', flex: 2.2),
          ResponsiveTableColumn('Código'),
          ResponsiveTableColumn('Inscripción'),
          ResponsiveTableColumn('Asistencia', flex: 1.4),
          ResponsiveTableColumn('Calificación', flex: 1.3),
        ],
        rows: estudiantes
            .map(
              (item) => [
                Text(
                  item.estudiante.nombreCompleto,
                  key: Key(
                    'resumen_estudiante_${item.estudiante.estudianteId}',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  item.estudiante.codigo?.isNotEmpty == true
                      ? item.estudiante.codigo!
                      : 'Sin código',
                ),
                const Text('Activa'),
                _AttendanceLabel(item: item),
                _GradeDetails(item: item),
              ],
            )
            .toList(growable: false),
      );
}

class _AttendanceChip extends StatelessWidget {
  const _AttendanceChip({required this.item});

  final ResumenAcademicoEstudiante item;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: const Icon(Icons.fact_check_outlined, size: 18),
        label: _AttendanceLabel(item: item),
      );
}

class _AttendanceLabel extends StatelessWidget {
  const _AttendanceLabel({required this.item});

  final ResumenAcademicoEstudiante item;

  @override
  Widget build(BuildContext context) {
    if (item.porcentajeAsistencia == null) {
      return const Text('Sin asistencia');
    }
    return Text(
      '${_number(item.porcentajeAsistencia!)} % · '
      '${item.presentes} P / ${item.ausentes} A / ${item.licencias} L',
    );
  }
}

class _GradeChip extends StatelessWidget {
  const _GradeChip({required this.item});

  final ResumenAcademicoEstudiante item;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: const Icon(Icons.grading_outlined, size: 18),
        label: _GradeLabel(item: item),
      );
}

class _GradeLabel extends StatelessWidget {
  const _GradeLabel({required this.item});

  final ResumenAcademicoEstudiante item;

  @override
  Widget build(BuildContext context) {
    if (item.promedioCalificaciones == null) {
      return const Text('Sin calificación');
    }
    final cantidad = item.calificaciones.length;
    return Text(
      '${_number(item.promedioCalificaciones!)} / 100'
      ' · $cantidad ${cantidad == 1 ? 'registro' : 'registros'}',
    );
  }
}

class _GradeDetails extends StatelessWidget {
  const _GradeDetails({required this.item});

  final ResumenAcademicoEstudiante item;

  @override
  Widget build(BuildContext context) {
    if (item.calificaciones.isEmpty) {
      return const Text('Sin calificación');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promedio: ${_number(item.promedioCalificaciones!)} / 100',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        for (final calificacion in item.calificaciones)
          Text(
            '${calificacion.tipoEvaluacion}: '
            '${_number(calificacion.nota)} / 100',
          ),
      ],
    );
  }
}

String _number(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);
