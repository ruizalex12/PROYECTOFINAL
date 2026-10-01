import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/periodo_academico.dart';
import '../controllers/periodo_academico_controller.dart';

class PeriodoAcademicoFormDialog extends StatefulWidget {
  const PeriodoAcademicoFormDialog({super.key, this.periodo});

  final PeriodoAcademico? periodo;

  @override
  State<PeriodoAcademicoFormDialog> createState() =>
      _PeriodoAcademicoFormDialogState();
}

class _PeriodoAcademicoFormDialogState
    extends State<PeriodoAcademicoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _inicioError;
  String? _finError;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.periodo?.nombre);
    _fechaInicio = widget.periodo?.fechaInicio;
    _fechaFin = widget.periodo?.fechaFin;
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool start) async {
    final current = start ? _fechaInicio : _fechaFin;
    final selected = await showDatePicker(
      context: context,
      initialDate: current ?? _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: start
          ? 'Selecciona la fecha de inicio'
          : 'Selecciona la fecha de finalización',
    );
    if (selected == null) return;
    setState(() {
      if (start) {
        _fechaInicio = selected;
        _inicioError = null;
      } else {
        _fechaFin = selected;
        _finError = null;
      }
      _error = null;
    });
  }

  String _date(DateTime? value) {
    if (value == null) return '';
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  Future<void> _guardar() async {
    final formValid = _formKey.currentState!.validate();
    setState(() {
      _inicioError =
          _fechaInicio == null ? 'Selecciona la fecha de inicio.' : null;
      _finError =
          _fechaFin == null ? 'Selecciona la fecha de finalización.' : null;
      _error = null;
    });
    if (!formValid || _fechaInicio == null || _fechaFin == null) return;
    if (_fechaFin!.isBefore(_fechaInicio!)) {
      setState(() {
        _finError =
            'La fecha de finalización no puede ser anterior a la fecha de inicio.';
      });
      return;
    }
    final error = await context.read<PeriodoAcademicoController>().guardar(
          existente: widget.periodo,
          nombre: _nombre.text,
          fechaInicio: _fechaInicio,
          fechaFin: _fechaFin,
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
    final saving = context.watch<PeriodoAcademicoController>().saving;
    return AlertDialog(
      title: Text(
        widget.periodo == null
            ? 'Nuevo periodo académico'
            : 'Editar periodo académico',
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombre,
                  autofocus: true,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Ej. Gestión 2027',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa el nombre del periodo académico.'
                      : null,
                ),
                const SizedBox(height: 8),
                _DateField(
                  label: 'Fecha de inicio *',
                  value: _date(_fechaInicio),
                  error: _inicioError,
                  onTap: () => _selectDate(true),
                ),
                const SizedBox(height: 14),
                _DateField(
                  label: 'Fecha de finalización *',
                  value: _date(_fechaFin),
                  error: _finError,
                  onTap: () => _selectDate(false),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
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
          child: Text(saving ? 'Guardando...' : 'Guardar periodo'),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.error,
    required this.onTap,
  });

  final String label;
  final String value;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: error,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          child: Text(value.isEmpty ? 'Seleccionar fecha' : value),
        ),
      );
}
