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
  late final TextEditingController _direccion;
  late final TextEditingController _correo;
  late final TextEditingController _rol;
  late final TextEditingController _fechaNacimiento;
  late final TextEditingController _especialidad;
  late final TextEditingController _tituloProfesional;
  late final TextEditingController _gradoAcademico;
  late final TextEditingController _fechaIncorporacion;
  late final TextEditingController _observaciones;
  String? _sexo;
  DateTime? _nacimiento;
  DateTime? _incorporacion;
  String? _error;

  @override
  void initState() {
    super.initState();
    final docente = widget.docente;
    _nombres = TextEditingController(text: docente.nombres);
    _apellidos = TextEditingController(text: docente.apellidos);
    _ci = TextEditingController(text: docente.ci);
    _telefono = TextEditingController(text: docente.telefono);
    _direccion = TextEditingController(text: docente.direccion);
    _correo = TextEditingController(text: docente.correo);
    _rol = TextEditingController(text: 'DOCENTE');
    _nacimiento = docente.fechaNacimiento;
    _fechaNacimiento = TextEditingController(text: _isoDate(_nacimiento));
    _sexo = const ['MASCULINO', 'FEMENINO'].contains(docente.sexo)
        ? docente.sexo
        : null;
    _especialidad = TextEditingController(text: docente.especialidad);
    _tituloProfesional = TextEditingController(text: docente.tituloProfesional);
    _gradoAcademico = TextEditingController(text: docente.gradoAcademico);
    _incorporacion = docente.fechaIncorporacion;
    _fechaIncorporacion = TextEditingController(text: _isoDate(_incorporacion));
    _observaciones = TextEditingController(text: docente.observaciones);
  }

  @override
  void dispose() {
    for (final controller in [
      _nombres,
      _apellidos,
      _ci,
      _telefono,
      _direccion,
      _correo,
      _rol,
      _fechaNacimiento,
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

  String _isoDate(DateTime? value) => value == null
      ? ''
      : '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate({required bool birth}) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: birth
          ? (_nacimiento ?? DateTime(now.year - 25))
          : (_incorporacion ?? now),
      firstDate: birth ? DateTime(1900) : DateTime(1950),
      lastDate: birth ? now : DateTime(now.year + 10),
      helpText: birth
          ? 'Seleccionar fecha de nacimiento'
          : 'Seleccionar fecha de incorporación',
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (birth) {
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
    final error = await context.read<DocenteController>().actualizar(
          docente: widget.docente,
          nombres: _nombres.text,
          apellidos: _apellidos.text,
          ci: _ci.text,
          telefono: _telefono.text,
          direccion: _direccion.text,
          sexo: _sexo!,
          fechaNacimiento: _nacimiento!,
          especialidad: _especialidad.text,
          tituloProfesional: _tituloProfesional.text,
          gradoAcademico: _gradoAcademico.text,
          fechaIncorporacion: _incorporacion,
          observaciones: _observaciones.text,
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: const Text('Editar docente'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _title(context, 'DATOS PERSONALES'),
                _fields([
                  TextFormField(
                    key: const Key('docente_nombres'),
                    controller: _nombres,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Nombres *'),
                    validator: DocenteFormValidator.requiredNames,
                  ),
                  TextFormField(
                    key: const Key('docente_apellidos'),
                    controller: _apellidos,
                    decoration: const InputDecoration(labelText: 'Apellidos *'),
                    validator: DocenteFormValidator.requiredLastNames,
                  ),
                  TextFormField(
                    key: const Key('docente_ci'),
                    controller: _ci,
                    decoration: const InputDecoration(labelText: 'CI *'),
                    validator: DocenteFormValidator.requiredCi,
                  ),
                  TextFormField(
                    controller: _telefono,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                  ),
                  TextFormField(
                    key: const Key('docente_direccion'),
                    controller: _direccion,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                  ),
                  DropdownButtonFormField<String>(
                    key: const Key('docente_sexo'),
                    initialValue: _sexo,
                    decoration: const InputDecoration(labelText: 'Sexo *'),
                    items: const [
                      DropdownMenuItem(
                          value: 'MASCULINO', child: Text('Masculino')),
                      DropdownMenuItem(
                          value: 'FEMENINO', child: Text('Femenino')),
                    ],
                    onChanged: saving
                        ? null
                        : (value) => setState(() => _sexo = value),
                    validator: DocenteFormValidator.requiredSex,
                  ),
                  _dateField(
                    key: const Key('docente_fecha_nacimiento'),
                    controller: _fechaNacimiento,
                    label: 'Fecha de nacimiento *',
                    onTap: () => _pickDate(birth: true),
                    validator: (_) =>
                        DocenteFormValidator.requiredBirthDate(_nacimiento),
                  ),
                  TextFormField(
                    key: const Key('docente_correo_solo_lectura'),
                    controller: _correo,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  TextFormField(
                    key: const Key('docente_rol_solo_lectura'),
                    controller: _rol,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Rol'),
                  ),
                ]),
                const SizedBox(height: 22),
                _title(context, 'DATOS PROFESIONALES'),
                _fields([
                  TextFormField(
                    key: const Key('docente_especialidad'),
                    controller: _especialidad,
                    decoration:
                        const InputDecoration(labelText: 'Especialidad *'),
                    validator: DocenteFormValidator.requiredSpecialty,
                  ),
                  TextFormField(
                    key: const Key('docente_titulo_profesional'),
                    controller: _tituloProfesional,
                    decoration:
                        const InputDecoration(labelText: 'Título profesional'),
                  ),
                  TextFormField(
                    key: const Key('docente_grado_academico'),
                    controller: _gradoAcademico,
                    decoration:
                        const InputDecoration(labelText: 'Grado académico'),
                  ),
                  _dateField(
                    key: const Key('docente_fecha_incorporacion'),
                    controller: _fechaIncorporacion,
                    label: 'Fecha de incorporación',
                    onTap: () => _pickDate(birth: false),
                  ),
                ]),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('docente_observaciones'),
                  controller: _observaciones,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    alignLabelWithHint: true,
                  ),
                ),
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
          key: const Key('docente_guardar'),
          onPressed: saving ? null : _guardar,
          child: Text(saving ? 'Guardando...' : 'Guardar cambios'),
        ),
      ],
    );
  }

  Widget _title(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
              ),
        ),
      );

  Widget _fields(List<Widget> fields) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = (screenWidth - 88).clamp(0.0, 720.0).toDouble();
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
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month_outlined),
        ),
      );
}
