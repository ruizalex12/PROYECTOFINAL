import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/asignacion_docente.dart';
import '../controllers/asignacion_docente_controller.dart';

class AsignacionDocenteFormDialog extends StatefulWidget {
  const AsignacionDocenteFormDialog({
    super.key,
    required this.options,
    this.asignacion,
  });

  final AsignacionDocenteOptions options;
  final AsignacionDocente? asignacion;

  @override
  State<AsignacionDocenteFormDialog> createState() =>
      _AsignacionDocenteFormDialogState();
}

class _AsignacionDocenteFormDialogState
    extends State<AsignacionDocenteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _docenteId;
  int? _asignaturaId;
  int? _periodoId;
  String? _error;

  @override
  void initState() {
    super.initState();
    final current = widget.asignacion;
    _docenteId =
        widget.options.docentes.any((item) => item.id == current?.docenteId)
            ? current?.docenteId
            : null;
    _asignaturaId = widget.options.asignaturas
            .any((item) => item.id == current?.asignatura.id)
        ? current?.asignatura.id
        : null;
    _periodoId =
        widget.options.periodos.any((item) => item.id == current?.periodo.id)
            ? current?.periodo.id
            : null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    final error = await context.read<AsignacionDocenteController>().guardar(
          existente: widget.asignacion,
          docenteId: _docenteId!,
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
    final saving = context.watch<AsignacionDocenteController>().saving;
    return AlertDialog(
      title: Text(
        widget.asignacion == null
            ? 'Nueva asignación docente'
            : 'Editar asignación',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _docenteId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Docente *'),
                  items: widget.options.docentes
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            '${item.nombre} · ${item.correo}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: saving
                      ? null
                      : (value) => setState(() => _docenteId = value),
                  validator: (value) =>
                      value == null ? 'Seleccione un docente activo.' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: _asignaturaId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Asignatura *'),
                  items: widget.options.asignaturas
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            '${item.codigo} · ${item.nombre}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: saving
                      ? null
                      : (value) => setState(() => _asignaturaId = value),
                  validator: (value) => value == null
                      ? 'Seleccione una asignatura activa.'
                      : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: _periodoId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Periodo académico *',
                  ),
                  items: widget.options.periodos
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.nombre),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: saving
                      ? null
                      : (value) => setState(() => _periodoId = value),
                  validator: (value) =>
                      value == null ? 'Seleccione un periodo activo.' : null,
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
          child: Text(saving ? 'Guardando...' : 'Guardar asignación'),
        ),
      ],
    );
  }
}
