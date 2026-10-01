import 'package:flutter/material.dart';

import '../../domain/entities/consulta_calificacion.dart';

class CalificacionAdminDetailDialog extends StatelessWidget {
  const CalificacionAdminDetailDialog({super.key, required this.item});
  final ConsultaCalificacion item;

  @override
  Widget build(BuildContext context) => AlertDialog(
        key: const Key('detalle_calificacion_solo_lectura'),
        title: const Text('Detalle de calificación'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('Estudiante', item.estudianteNombre),
                _field('Código', item.estudianteCodigo ?? 'Sin código'),
                _field('CI', item.estudianteCi),
                _field('Asignatura', item.asignaturaNombre),
                _field('Periodo', item.periodoNombre),
                _field('Docente', item.docenteNombre),
                _field('Tipo de evaluación', item.tipoEvaluacion),
                _field('Nota', _nota(item.nota)),
                _field('Observación', item.observacion ?? 'Sin observación'),
                _field('Fecha de registro', _dateTime(item.fechaRegistro)),
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

  Widget _field(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          SelectableText(value),
        ]),
      );

  String _nota(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);

  String _dateTime(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
