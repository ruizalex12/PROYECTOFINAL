import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/inscripcion.dart';
import '../controllers/inscripcion_controller.dart';

class InscripcionFormDialog extends StatefulWidget {
  const InscripcionFormDialog({
    super.key,
    required this.options,
    this.inscripcion,
  });

  final InscripcionOptions options;
  final Inscripcion? inscripcion;

  @override
  State<InscripcionFormDialog> createState() => _InscripcionFormDialogState();
}

class _InscripcionFormDialogState extends State<InscripcionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _estudianteId;
  int? _asignaturaId;
  int? _periodoId;
  String? _error;

  late final List<InscripcionOption> _estudiantes;
  late final List<InscripcionOption> _asignaturas;
  late final List<InscripcionOption> _periodos;

  @override
  void initState() {
    super.initState();
    final current = widget.inscripcion;
    _estudiantes = _withHistorical(
      widget.options.estudiantes,
      current == null
          ? null
          : InscripcionOption(
              id: current.estudianteId,
              label: current.estudianteNombre,
            ),
      current?.estudianteActivo ?? true,
    );
    _asignaturas = _withHistorical(
      widget.options.asignaturas,
      current == null
          ? null
          : InscripcionOption(
              id: current.asignaturaId,
              label:
                  '${current.asignaturaCodigo} · ${current.asignaturaNombre}',
            ),
      current?.asignaturaActiva ?? true,
    );
    _periodos = _withHistorical(
      widget.options.periodos,
      current == null
          ? null
          : InscripcionOption(
              id: current.periodoId,
              label: current.periodoNombre,
            ),
      current?.periodoActivo ?? true,
    );
    _estudianteId = current?.estudianteId;
    _asignaturaId = current?.asignaturaId;
    _periodoId = current?.periodoId;
  }

  List<InscripcionOption> _withHistorical(
    List<InscripcionOption> active,
    InscripcionOption? current,
    bool currentActive,
  ) {
    if (current == null || active.any((item) => item.id == current.id)) {
      return active;
    }
    return [
      InscripcionOption(
        id: current.id,
        label: currentActive ? current.label : '${current.label} (inactivo)',
      ),
      ...active,
    ];
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    final error = await context.read<InscripcionController>().guardar(
          existente: widget.inscripcion,
          estudianteId: _estudianteId!,
          asignaturaId: _asignaturaId!,
          periodoId: _periodoId!,
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
    final saving = context.watch<InscripcionController>().saving;
    return AlertDialog(
      title: Text(
        widget.inscripcion == null ? 'Nueva inscripción' : 'Editar inscripción',
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _select(
                  label: 'Estudiante *',
                  value: _estudianteId,
                  items: _estudiantes,
                  saving: saving,
                  onChanged: (value) => setState(() => _estudianteId = value),
                  error: 'Seleccione un estudiante activo.',
                ),
                const SizedBox(height: 14),
                _select(
                  label: 'Asignatura *',
                  value: _asignaturaId,
                  items: _asignaturas,
                  saving: saving,
                  onChanged: (value) => setState(() => _asignaturaId = value),
                  error: 'Seleccione una asignatura activa.',
                ),
                const SizedBox(height: 14),
                _select(
                  label: 'Periodo académico *',
                  value: _periodoId,
                  items: _periodos,
                  saving: saving,
                  onChanged: (value) => setState(() => _periodoId = value),
                  error: 'Seleccione un periodo activo.',
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: saving ? null : _guardar,
          child: Text(saving ? 'Guardando...' : 'Guardar inscripción'),
        ),
      ],
    );
  }

  Widget _select({
    required String label,
    required int? value,
    required List<InscripcionOption> items,
    required bool saving,
    required ValueChanged<int?> onChanged,
    required String error,
  }) =>
      DropdownButtonFormField<int>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item.id,
                child: Text(item.label, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(growable: false),
        onChanged: saving ? null : onChanged,
        validator: (value) => value == null ? error : null,
      );
}
