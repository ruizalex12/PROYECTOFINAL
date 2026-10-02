import 'package:flutter/material.dart';

import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/docente.dart';

class DocenteDetailDialog extends StatelessWidget {
  const DocenteDetailDialog({super.key, required this.docente});

  final Docente docente;

  @override
  Widget build(BuildContext context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: const Text('Detalle del docente'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _title(context, 'DATOS PERSONALES'),
                _fields(context, [
                  _field('Nombres', docente.nombres),
                  _field('Apellidos', docente.apellidos),
                  _field('CI', docente.ci),
                  _field('Correo', docente.correo),
                  _field('Teléfono', docente.telefono),
                  _field('Dirección', docente.direccion),
                  _field('Sexo', docente.sexoLabel),
                  _field('Fecha de nacimiento', _date(docente.fechaNacimiento)),
                  _status(),
                ]),
                const SizedBox(height: 20),
                _title(context, 'DATOS PROFESIONALES'),
                _fields(context, [
                  _field('Especialidad', docente.especialidad),
                  _field('Título profesional', docente.tituloProfesional),
                  _field('Grado académico', docente.gradoAcademico),
                  _field('Fecha de incorporación',
                      _date(docente.fechaIncorporacion)),
                  _field('Observaciones', docente.observaciones),
                ]),
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      );

  Widget _title(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
              ),
        ),
      );

  Widget _fields(BuildContext context, List<_DetailField> fields) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = (screenWidth - 88).clamp(0.0, 620.0).toDouble();
    final twoColumns = availableWidth >= 560;
    final fieldWidth = twoColumns ? (availableWidth - 12) / 2 : availableWidth;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: fields
          .map((field) => field.build(context, fieldWidth))
          .toList(growable: false),
    );
  }

  _DetailField _field(String label, String? value) => _DetailField(
        label: label,
        value: value == null || value.trim().isEmpty ? 'Sin registrar' : value,
      );

  _DetailField _status() => _DetailField(
        label: 'Estado',
        child: StatusBadge(active: docente.estado),
      );

  String? _date(DateTime? value) => value == null
      ? null
      : '${value.day.toString().padLeft(2, '0')}/'
          '${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _DetailField {
  const _DetailField({required this.label, this.value, this.child});

  final String label;
  final String? value;
  final Widget? child;

  Widget build(BuildContext context, double width) => SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 3),
            if (child != null)
              Align(alignment: Alignment.centerLeft, child: child)
            else
              Text(
                value!,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
          ],
        ),
      );
}
