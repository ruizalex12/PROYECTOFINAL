import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/estudiante.dart';
import '../controllers/estudiante_controller.dart';

class EstudianteFormDialog extends StatefulWidget {
  const EstudianteFormDialog({super.key, this.estudiante});

  final Estudiante? estudiante;

  @override
  State<EstudianteFormDialog> createState() => _EstudianteFormDialogState();
}

class _EstudianteFormDialogState extends State<EstudianteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombres;
  late final TextEditingController _apellidos;
  late final TextEditingController _ci;
  late final TextEditingController _telefono;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombres = TextEditingController(text: widget.estudiante?.nombres);
    _apellidos = TextEditingController(text: widget.estudiante?.apellidos);
    _ci = TextEditingController(text: widget.estudiante?.ci);
    _telefono = TextEditingController(text: widget.estudiante?.telefono);
  }

  @override
  void dispose() {
    _nombres.dispose();
    _apellidos.dispose();
    _ci.dispose();
    _telefono.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    final controller = context.read<EstudianteController>();
    final error = await controller.guardar(
      existente: widget.estudiante,
      nombres: _nombres.text,
      apellidos: _apellidos.text,
      ci: _ci.text,
      telefono: _telefono.text,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, controller.ultimoGuardado);
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<EstudianteController>().saving;
    return AlertDialog(
      title: Text(
        widget.estudiante == null ? 'Nuevo estudiante' : 'Editar estudiante',
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.estudiante == null)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'El código será generado automáticamente por el sistema.',
                    ),
                  )
                else
                  TextFormField(
                    key: const Key('estudiante-codigo-solo-lectura'),
                    initialValue: widget.estudiante!.codigo,
                    readOnly: true,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Código'),
                  ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombres,
                  autofocus: true,
                  maxLength: 100,
                  decoration: const InputDecoration(labelText: 'Nombres *'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa los nombres del estudiante.'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _apellidos,
                  maxLength: 100,
                  decoration: const InputDecoration(labelText: 'Apellidos *'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa los apellidos del estudiante.'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ci,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: 'CI *'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa el CI del estudiante.'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _telefono,
                  keyboardType: TextInputType.phone,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    helperText: 'Opcional',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
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
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: saving ? null : _guardar,
          child: Text(saving ? 'Guardando...' : 'Guardar estudiante'),
        ),
      ],
    );
  }
}
