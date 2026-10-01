import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/usuario.dart';
import '../controllers/usuario_controller.dart';
import 'usuario_form_validator.dart';

class UsuarioFormDialog extends StatefulWidget {
  const UsuarioFormDialog({super.key, this.usuario});

  final Usuario? usuario;

  @override
  State<UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends State<UsuarioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombres;
  late final TextEditingController _apellidos;
  late final TextEditingController _ci;
  late final TextEditingController _telefono;
  late final TextEditingController _correo;
  final _password = TextEditingController();
  final _confirmacion = TextEditingController();
  UsuarioRol? _rol;
  bool _ocultarPassword = true;
  String? _error;

  bool get _editing => widget.usuario != null;

  @override
  void initState() {
    super.initState();
    _nombres = TextEditingController(text: widget.usuario?.nombres);
    _apellidos = TextEditingController(text: widget.usuario?.apellidos);
    _ci = TextEditingController(text: widget.usuario?.ci);
    _telefono = TextEditingController(text: widget.usuario?.telefono);
    _correo = TextEditingController(text: widget.usuario?.correo);
    _rol = widget.usuario?.rol;
  }

  @override
  void dispose() {
    _nombres.dispose();
    _apellidos.dispose();
    _ci.dispose();
    _telefono.dispose();
    _correo.dispose();
    _password.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    final controller = context.read<UsuarioController>();
    final error = _editing
        ? await controller.actualizar(
            usuario: widget.usuario!,
            nombres: _nombres.text,
            apellidos: _apellidos.text,
            ci: _ci.text,
            telefono: _telefono.text,
          )
        : await controller.crear(
            nombres: _nombres.text,
            apellidos: _apellidos.text,
            ci: _ci.text,
            telefono: _telefono.text,
            correo: _correo.text,
            contrasena: _password.text,
            rol: _rol!,
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
    final saving = context.watch<UsuarioController>().saving;
    return AlertDialog(
      title: Text(_editing ? 'Editar usuario' : 'Nuevo usuario'),
      content: SizedBox(
        width: 560,
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
                  validator: UsuarioFormValidator.nombres,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _apellidos,
                  maxLength: 100,
                  decoration: const InputDecoration(labelText: 'Apellidos *'),
                  validator: UsuarioFormValidator.apellidos,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ci,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: 'CI *'),
                  validator: UsuarioFormValidator.ci,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _telefono,
                  maxLength: 30,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    helperText: 'Opcional',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _correo,
                  enabled: !_editing,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo *',
                    helperText: _editing
                        ? 'El correo pertenece a la cuenta de autenticación y requiere un proceso administrativo separado.'
                        : null,
                  ),
                  validator: UsuarioFormValidator.correo,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<UsuarioRol>(
                  initialValue: _rol,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Rol *'),
                  items: UsuarioRol.values
                      .map((rol) => DropdownMenuItem(
                            value: rol,
                            child: Text(rol.label),
                          ))
                      .toList(growable: false),
                  onChanged: _editing || saving
                      ? null
                      : (value) => setState(() => _rol = value),
                  validator: (value) =>
                      value == null ? 'Seleccione un rol.' : null,
                ),
                if (_editing)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'El rol no puede modificarse desde este formulario.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                else ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    obscureText: _ocultarPassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña *',
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _ocultarPassword = !_ocultarPassword,
                        ),
                        icon: Icon(_ocultarPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      ),
                    ),
                    validator: UsuarioFormValidator.password,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmacion,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña *',
                    ),
                    validator: (value) => UsuarioFormValidator.confirmacion(
                      value,
                      _password.text,
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
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
          child: Text(saving
              ? 'Guardando...'
              : _editing
                  ? 'Guardar cambios'
                  : 'Crear usuario'),
        ),
      ],
    );
  }
}
