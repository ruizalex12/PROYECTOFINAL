import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/asignatura.dart';
import '../controllers/asignatura_controller.dart';

class AsignaturaFormDialog extends StatefulWidget {
  const AsignaturaFormDialog({super.key, this.asignatura});

  final Asignatura? asignatura;

  @override
  State<AsignaturaFormDialog> createState() => _AsignaturaFormDialogState();
}

class _AsignaturaFormDialogState extends State<AsignaturaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigo;
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  String? _error;

  @override
  void initState() {
    super.initState();
    _codigo = TextEditingController(text: widget.asignatura?.codigo ?? '');
    _nombre = TextEditingController(text: widget.asignatura?.nombre ?? '');
    _descripcion =
        TextEditingController(text: widget.asignatura?.descripcion ?? '');
  }

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    final error = await context.read<AsignaturaController>().guardar(
          existente: widget.asignatura,
          codigo: _codigo.text,
          nombre: _nombre.text,
          descripcion: _descripcion.text,
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
    final saving = context.watch<AsignaturaController>().saving;
    return AlertDialog(
      title: Text(
        widget.asignatura == null ? 'Nueva asignatura' : 'Editar asignatura',
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codigo,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: 'Código'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'El código es obligatorio.'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombre,
                  maxLength: 150,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'El nombre es obligatorio.'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descripcion,
                  maxLength: 300,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
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
          child: Text(saving ? 'Guardando...' : 'Guardar'),
        ),
      ],
    );
  }
}
