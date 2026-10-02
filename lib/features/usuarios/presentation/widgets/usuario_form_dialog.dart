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
  final _direccion = TextEditingController();
  final _fechaNacimiento = TextEditingController();
  final _password = TextEditingController();
  final _confirmacion = TextEditingController();
  final _especialidad = TextEditingController();
  final _tituloProfesional = TextEditingController();
  final _gradoAcademico = TextEditingController();
  final _fechaIncorporacion = TextEditingController();
  final _observaciones = TextEditingController();
  UsuarioRol? _rol;
  SexoUsuario? _sexo;
  DateTime? _nacimiento;
  DateTime? _incorporacion;
  bool _ocultarPassword = true;
  String? _error;

  bool get _editing => widget.usuario != null;
  bool get _esDocente => !_editing && _rol == UsuarioRol.docente;

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
    for (final controller in [
      _nombres,
      _apellidos,
      _ci,
      _telefono,
      _direccion,
      _fechaNacimiento,
      _correo,
      _password,
      _confirmacion,
      _especialidad,
      _tituloProfesional,
      _gradoAcademico,
      _fechaIncorporacion,
      _observaciones,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _cambiarRol(UsuarioRol? value) {
    if (value == _rol) return;
    setState(() {
      _rol = value;
      if (value == UsuarioRol.docente && _sexo == SexoUsuario.otro) {
        _sexo = null;
      }
      if (value != UsuarioRol.docente) _limpiarDatosDocente();
    });
  }

  void _limpiarDatosDocente() {
    _especialidad.clear();
    _tituloProfesional.clear();
    _gradoAcademico.clear();
    _fechaIncorporacion.clear();
    _observaciones.clear();
    _incorporacion = null;
  }

  String _isoDate(DateTime value) => '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  Future<void> _seleccionarFecha({required bool nacimiento}) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: nacimiento
          ? (_nacimiento ?? DateTime(now.year - 20))
          : (_incorporacion ?? now),
      firstDate: nacimiento ? DateTime(1900) : DateTime(1950),
      lastDate: nacimiento ? now : DateTime(now.year + 10),
      helpText: nacimiento
          ? 'Seleccionar fecha de nacimiento'
          : 'Seleccionar fecha de incorporación',
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (nacimiento) {
        _nacimiento = selected;
        _fechaNacimiento.text = _isoDate(selected);
      } else {
        _incorporacion = selected;
        _fechaIncorporacion.text = _isoDate(selected);
      }
    });
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
            direccion: _direccion.text,
            sexo: _sexo,
            fechaNacimiento: _fechaNacimiento.text,
            correo: _correo.text,
            contrasena: _password.text,
            rol: _rol!,
            docente: _esDocente
                ? DatosDocenteCreacion(
                    especialidad: _especialidad.text,
                    tituloProfesional: _tituloProfesional.text,
                    gradoAcademico: _gradoAcademico.text,
                    fechaIncorporacion: _fechaIncorporacion.text,
                    observaciones: _observaciones.text,
                  )
                : null,
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Text(_editing ? 'Editar usuario' : 'Nuevo usuario'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle(
                    context, 'DATOS PERSONALES', Icons.badge_outlined),
                const SizedBox(height: 14),
                _responsiveFields([
                  TextFormField(
                    key: const Key('usuario-nombres'),
                    controller: _nombres,
                    autofocus: true,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Nombres *'),
                    validator: UsuarioFormValidator.nombres,
                  ),
                  TextFormField(
                    key: const Key('usuario-apellidos'),
                    controller: _apellidos,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Apellidos *'),
                    validator: UsuarioFormValidator.apellidos,
                  ),
                  TextFormField(
                    key: const Key('usuario-ci'),
                    controller: _ci,
                    maxLength: 30,
                    decoration: const InputDecoration(labelText: 'CI *'),
                    validator: UsuarioFormValidator.ci,
                  ),
                  TextFormField(
                    controller: _telefono,
                    maxLength: 30,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      helperText: 'Opcional',
                    ),
                  ),
                  if (!_editing)
                    TextFormField(
                      key: const Key('usuario-direccion'),
                      controller: _direccion,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        helperText: 'Opcional',
                      ),
                    ),
                  if (!_editing)
                    DropdownButtonFormField<SexoUsuario>(
                      key: ValueKey('usuario-sexo-${_rol?.databaseValue}'),
                      initialValue: _sexo,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: _esDocente ? 'Sexo *' : 'Sexo',
                      ),
                      items: (_esDocente
                              ? const [
                                  SexoUsuario.masculino,
                                  SexoUsuario.femenino,
                                ]
                              : SexoUsuario.values)
                          .map((sexo) => DropdownMenuItem(
                                value: sexo,
                                child: Text(sexo.label),
                              ))
                          .toList(growable: false),
                      onChanged: saving
                          ? null
                          : (value) => setState(() => _sexo = value),
                      validator:
                          _esDocente ? UsuarioFormValidator.sexoDocente : null,
                    ),
                  if (!_editing)
                    _dateField(
                      key: const Key('usuario-fecha-nacimiento'),
                      controller: _fechaNacimiento,
                      label: _esDocente
                          ? 'Fecha de nacimiento *'
                          : 'Fecha de nacimiento',
                      onTap: () => _seleccionarFecha(nacimiento: true),
                      validator: _esDocente
                          ? UsuarioFormValidator.fechaNacimientoDocente
                          : UsuarioFormValidator.fechaOpcional,
                    ),
                ]),
                const SizedBox(height: 20),
                _sectionTitle(context, 'DATOS DE ACCESO', Icons.lock_outline),
                const SizedBox(height: 14),
                _responsiveFields([
                  TextFormField(
                    key: const Key('usuario-correo'),
                    controller: _correo,
                    enabled: !_editing,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo *',
                      helperText: _editing
                          ? 'El correo requiere un proceso administrativo separado.'
                          : null,
                    ),
                    validator: UsuarioFormValidator.correo,
                  ),
                  DropdownButtonFormField<UsuarioRol>(
                    key: const Key('usuario-rol'),
                    initialValue: _rol,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Rol *'),
                    items: UsuarioRol.values
                        .map((rol) => DropdownMenuItem(
                              value: rol,
                              child: Text(rol.label),
                            ))
                        .toList(growable: false),
                    onChanged: _editing || saving ? null : _cambiarRol,
                    validator: (value) =>
                        value == null ? 'Seleccione un rol.' : null,
                  ),
                  if (!_editing)
                    TextFormField(
                      key: const Key('usuario-password'),
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
                  if (!_editing)
                    TextFormField(
                      key: const Key('usuario-confirmacion'),
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
                ]),
                if (_editing)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'El rol y los datos profesionales no pueden modificarse desde este formulario.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                if (_esDocente) ...[
                  const SizedBox(height: 20),
                  Container(
                    key: const Key('usuario-seccion-docente'),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionTitle(
                          context,
                          'INFORMACIÓN PROFESIONAL DEL DOCENTE',
                          Icons.school_outlined,
                        ),
                        const SizedBox(height: 14),
                        _responsiveFields([
                          TextFormField(
                            key: const Key('usuario-especialidad'),
                            controller: _especialidad,
                            maxLength: 150,
                            decoration: const InputDecoration(
                              labelText: 'Especialidad *',
                            ),
                            validator: UsuarioFormValidator.especialidad,
                          ),
                          TextFormField(
                            controller: _tituloProfesional,
                            maxLength: 200,
                            decoration: const InputDecoration(
                              labelText: 'Título profesional',
                            ),
                          ),
                          TextFormField(
                            controller: _gradoAcademico,
                            maxLength: 100,
                            decoration: const InputDecoration(
                              labelText: 'Grado académico',
                            ),
                          ),
                          _dateField(
                            key: const Key('usuario-fecha-incorporacion'),
                            controller: _fechaIncorporacion,
                            label: 'Fecha de incorporación',
                            onTap: () => _seleccionarFecha(nacimiento: false),
                          ),
                        ], nested: true),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('usuario-observaciones'),
                          controller: _observaciones,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Observaciones',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
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
          key: const Key('usuario-guardar'),
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

  Widget _sectionTitle(BuildContext context, String title, IconData icon) =>
      Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ],
      );

  Widget _responsiveFields(List<Widget> fields, {bool nested = false}) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = (screenWidth - 88).clamp(0.0, 720.0).toDouble();
    final availableWidth =
        (dialogWidth - (nested ? 32 : 0)).clamp(0.0, 720.0).toDouble();
    final twoColumns = availableWidth >= 600;
    final fieldWidth = twoColumns ? (availableWidth - 14) / 2 : availableWidth;
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      children: fields
          .map((field) => SizedBox(width: fieldWidth, child: field))
          .toList(),
    );
  }

  Widget _dateField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        key: key,
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          helperText: 'Opcional',
          suffixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        validator: validator ?? UsuarioFormValidator.fechaOpcional,
      );
}
