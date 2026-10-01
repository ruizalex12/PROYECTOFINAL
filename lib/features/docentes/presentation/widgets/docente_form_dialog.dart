import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/docente.dart';
import '../controllers/docente_controller.dart';
import 'docente_form_validator.dart';

class DocenteFormDialog extends StatefulWidget {
  const DocenteFormDialog({super.key, required this.docente});

  final Docente docente;

  @override
  State<DocenteFormDialog> createState() => _DocenteFormDialogState();
}

class _DocenteFormDialogState extends State<DocenteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombres;
  late final TextEditingController _apellidos;
  late final TextEditingController _ci;
  late final TextEditingController _telefono;
  late final TextEditingController _correo;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombres = TextEditingController(text: widget.docente.nombres);
    _apellidos = TextEditingController(text: widget.docente.apellidos);
    _ci = TextEditingController(text: widget.docente.ci);
    _telefono = TextEditingController(text: widget.docente.telefono);
    _correo = TextEditingController(text: widget.docente.correo);
  }

  @override
  void dispose() {
    _nombres.dispose();
    _apellidos.dispose();
    _ci.dispose();
    _telefono.dispose();
    _correo.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    final error = await context.read<DocenteController>().actualizar(
          docente: widget.docente,
          nombres: _nombres.text,
          apellidos: _apellidos.text,
          ci: _ci.text,
          telefono: _telefono.text,
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
    final saving = context.watch<DocenteController>().saving;
    return AlertDialog(
      title: const Text('Editar docente'),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombres,
                  autofocus: true,
                  maxLength: 100,
                  decoration: const InputDecoration(labelText: 'Nombres *'),
                  validator: DocenteFormValidator.requiredNames,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _apellidos,
                  maxLength: 100,
                  decoration: const InputDecoration(labelText: 'Apellidos *'),
                  validator: DocenteFormValidator.requiredLastNames,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ci,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: 'CI *'),
                  validator: DocenteFormValidator.requiredCi,
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
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('docente_correo_solo_lectura'),
                  controller: _correo,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    helperText:
                        'El correo pertenece a la cuenta de autenticación y requiere un proceso administrativo separado.',
                  ),
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
          child: Text(saving ? 'Guardando...' : 'Guardar cambios'),
        ),
      ],
    );
  }
}
