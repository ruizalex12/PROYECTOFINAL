import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/app_states.dart';
import '../../../asignaciones_docente/domain/entities/asignacion_docente.dart';
import '../../domain/entities/asistencia.dart';
import '../controllers/asistencia_controller.dart';

class AsistenciaPage extends StatefulWidget {
  const AsistenciaPage({super.key, required this.asignacion});

  final AsignacionDocente asignacion;

  @override
  State<AsistenciaPage> createState() => _AsistenciaPageState();
}

class _AsistenciaPageState extends State<AsistenciaPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AsistenciaController>().cargar(),
    );
  }

  Future<void> _seleccionarFecha(AsistenciaController controller) async {
    final initialDate = controller.fecha.isBefore(
      widget.asignacion.periodo.fechaInicio,
    )
        ? widget.asignacion.periodo.fechaInicio
        : controller.fecha.isAfter(widget.asignacion.periodo.fechaFin)
            ? widget.asignacion.periodo.fechaFin
            : controller.fecha;
    final value = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.asignacion.periodo.fechaInicio,
      lastDate: widget.asignacion.periodo.fechaFin,
    );
    if (value != null) await controller.cambiarFecha(value);
  }

  Future<void> _guardar(AsistenciaController controller) async {
    final error = await controller.guardar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Asistencia guardada correctamente.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AsistenciaController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.asignacion.asignatura.nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _seleccionarFecha(controller),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(_formatDate(controller.fecha)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _body(controller)),
          ],
        ),
      ),
      bottomNavigationBar: controller.state == AsistenciaViewState.data
          ? SafeArea(
              minimum: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed:
                    controller.saving ? null : () => _guardar(controller),
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  controller.saving ? 'Guardando...' : 'Guardar asistencia',
                ),
              ),
            )
          : null,
    );
  }

  Widget _body(AsistenciaController controller) => switch (controller.state) {
        AsistenciaViewState.loading => const AppLoadingState(
            message: 'Cargando asistencia...',
          ),
        AsistenciaViewState.empty => const AppEmptyState(
            icon: Icons.groups_outlined,
            title: 'No hay estudiantes inscritos.',
            message: 'No se puede registrar asistencia para esta asignatura.',
          ),
        AsistenciaViewState.error => AppErrorState(
            message: controller.errorMessage ??
                'No fue posible cargar la asistencia.',
            onRetry: controller.cargar,
          ),
        AsistenciaViewState.data => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _AsistenciaItem(
              key: ValueKey(controller.items[index].estudiante.inscripcionId),
              item: controller.items[index],
              onEstado: (value) => controller.cambiarEstado(index, value),
              onObservacion: (value) =>
                  controller.cambiarObservacion(index, value),
            ),
          ),
      };

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _AsistenciaItem extends StatelessWidget {
  const _AsistenciaItem({
    super.key,
    required this.item,
    required this.onEstado,
    required this.onObservacion,
  });

  final AsistenciaBorrador item;
  final ValueChanged<EstadoAsistencia> onEstado;
  final ValueChanged<String> onObservacion;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.estudiante.nombreCompleto,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (item.estudiante.codigo?.isNotEmpty == true) ...[
                const SizedBox(height: 2),
                Text(item.estudiante.codigo!),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<EstadoAsistencia>(
                initialValue: item.estado,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: EstadoAsistencia.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) onEstado(value);
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: item.observacion,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Observación (opcional)',
                ),
                onChanged: onObservacion,
              ),
            ],
          ),
        ),
      );
}
