import 'package:flutter/material.dart';

import '../../../../shared/widgets/responsive_table.dart';
import '../../../asistencia/domain/entities/asistencia.dart';
import '../../domain/entities/consulta_asistencia.dart';

class AsistenciaAdminTable extends StatelessWidget {
  const AsistenciaAdminTable(
      {super.key, required this.items, required this.onDetail});
  final List<ConsultaAsistencia> items;
  final ValueChanged<ConsultaAsistencia> onDetail;

  @override
  Widget build(BuildContext context) => ResponsiveTable(
        minimumWidth: 1450,
        columns: const [
          ResponsiveTableColumn('Fecha', flex: 1.1),
          ResponsiveTableColumn('Estudiante', flex: 1.9),
          ResponsiveTableColumn('Asignatura', flex: 1.8),
          ResponsiveTableColumn('Periodo académico', flex: 1.5),
          ResponsiveTableColumn('Docente', flex: 1.8),
          ResponsiveTableColumn('Estado', flex: 1.25),
          ResponsiveTableColumn('Observación', flex: 2),
          ResponsiveTableColumn('Acciones',
              flex: 1.4, alignment: Alignment.center),
        ],
        rows: items
            .map((item) => <Widget>[
                  Text(_date(item.fecha)),
                  _text(item.estudianteNombre, bold: true),
                  _text(item.asignaturaNombre),
                  _text(item.periodoNombre),
                  _text(item.docenteNombre),
                  Chip(label: Text(item.estado.databaseValue)),
                  _text(item.observacion ?? '—'),
                  TextButton.icon(
                      key: ValueKey('ver_detalle_asistencia_${item.id}'),
                      onPressed: () => onDetail(item),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Ver detalle')),
                ])
            .toList(growable: false),
      );

  Widget _text(String value, {bool bold = false}) => Text(value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: bold ? const TextStyle(fontWeight: FontWeight.w600) : null);
  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
