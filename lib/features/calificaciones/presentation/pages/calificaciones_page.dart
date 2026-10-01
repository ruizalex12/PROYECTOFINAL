import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/app_states.dart';
import '../../../asignaciones_docente/domain/entities/asignacion_docente.dart';
import '../../../estudiantes/domain/entities/estudiante_inscrito.dart';
import '../../domain/entities/calificacion.dart';
import '../controllers/calificaciones_controller.dart';

class CalificacionesPage extends StatefulWidget {
  const CalificacionesPage({super.key, required this.asignacion});

  final AsignacionDocente asignacion;

  @override
  State<CalificacionesPage> createState() => _CalificacionesPageState();
}

class _CalificacionesPageState extends State<CalificacionesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CalificacionesController>().cargar(),
    );
  }

  Future<void> _form(
    EstudianteInscrito estudiante, [
    Calificacion? calificacion,
  ]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<CalificacionesController>(),
        child: _CalificacionForm(
          estudiante: estudiante,
          calificacion: calificacion,
        ),
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calificación guardada correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalificacionesController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Calificaciones')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Text(
                widget.asignacion.asignatura.nombre,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _body(controller)),
          ],
        ),
      ),
    );
  }

  Widget _body(CalificacionesController controller) =>
      switch (controller.state) {
        CalificacionesViewState.loading => const AppLoadingState(
            message: 'Cargando calificaciones...',
          ),
        CalificacionesViewState.empty => const AppEmptyState(
            icon: Icons.groups_outlined,
            title: 'No hay estudiantes inscritos.',
            message:
                'No se pueden registrar calificaciones para esta asignatura.',
          ),
        CalificacionesViewState.error => AppErrorState(
            message: controller.errorMessage ??
                'No fue posible cargar las calificaciones.',
            onRetry: controller.cargar,
          ),
        CalificacionesViewState.data => RefreshIndicator(
            onRefresh: controller.cargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.estudiantes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final estudiante = controller.estudiantes[index];
                final notas =
                    controller.calificacionesDe(estudiante.inscripcionId);
                return Card(
                  child: ExpansionTile(
                    title: Text(
                      estudiante.nombreCompleto,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      notas.isEmpty
                          ? 'Sin calificaciones'
                          : '${notas.length} evaluación(es)',
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    children: [
                      for (final nota in notas)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(nota.tipoEvaluacion),
                          subtitle: nota.observacion == null
                              ? null
                              : Text(nota.observacion!),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatNota(nota.nota),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Editar',
                                onPressed: () => _form(estudiante, nota),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _form(estudiante),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Agregar calificación'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      };

  String _formatNota(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';
}

class _CalificacionForm extends StatefulWidget {
  const _CalificacionForm({
    required this.estudiante,
    this.calificacion,
  });

  final EstudianteInscrito estudiante;
  final Calificacion? calificacion;

  @override
  State<_CalificacionForm> createState() => _CalificacionFormState();
}

class _CalificacionFormState extends State<_CalificacionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tipo;
  late final TextEditingController _nota;
  late final TextEditingController _observacion;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tipo = TextEditingController(text: widget.calificacion?.tipoEvaluacion);
    _nota = TextEditingController(
      text: widget.calificacion == null
          ? ''
          : widget.calificacion!.nota.toString(),
    );
    _observacion =
        TextEditingController(text: widget.calificacion?.observacion);
  }

  @override
  void dispose() {
    _tipo.dispose();
    _nota.dispose();
    _observacion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    final error = await context.read<CalificacionesController>().guardar(
          existente: widget.calificacion,
          inscripcionId: widget.estudiante.inscripcionId,
          tipoEvaluacion: _tipo.text,
          nota: _nota.text,
          observacion: _observacion.text,
        );
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<CalificacionesController>().saving;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.calificacion == null
                    ? 'Nueva calificación'
                    : 'Editar calificación',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(widget.estudiante.nombreCompleto),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tipo,
                maxLength: 100,
                decoration:
                    const InputDecoration(labelText: 'Tipo de evaluación'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'El tipo de evaluación es obligatorio.'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nota,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(labelText: 'Nota (0 a 100)'),
                validator: (value) {
                  final parsed =
                      double.tryParse(value?.trim().replaceAll(',', '.') ?? '');
                  if (parsed == null) return 'Ingrese una nota válida.';
                  if (parsed < 0 || parsed > 100) {
                    return 'La nota debe estar entre 0 y 100.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _observacion,
                maxLength: 300,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observación (opcional)',
                ),
              ),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 10),
              ],
              FilledButton(
                onPressed: saving ? null : _guardar,
                child: Text(saving ? 'Guardando...' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
