import 'package:flutter/material.dart';

import '../../../asistencia/domain/entities/asistencia.dart';
import '../../domain/entities/consulta_asistencia.dart';

class AsistenciaAdminDetailDialog extends StatelessWidget {
  const AsistenciaAdminDetailDialog({super.key, required this.item});

  final ConsultaAsistencia item;

  @override
  Widget build(BuildContext context) => AlertDialog(
        key: const Key('detalle_asistencia_solo_lectura'),
        title: const Text('Detalle de asistencia'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('Estudiante', item.estudianteNombre),
                _field(
                  'Código / CI',
                  [item.estudianteCodigo, item.estudianteCi]
                      .where((value) => value?.isNotEmpty == true)
                      .join(' / '),
                ),
                _field('Asignatura', item.asignaturaNombre),
                _field('Periodo', item.periodoNombre),
                _field('Docente', item.docenteNombre),
                _field('Fecha', _date(item.fecha)),
                _field('Estado', item.estado.databaseValue),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            SelectableText(value),
          ],
        ),
      );

  String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  String _dateTime(DateTime value) {
    final local = value.toLocal();
    return '${_date(local)} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
