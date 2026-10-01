import 'package:flutter/material.dart';

import '../../../asistencia/domain/entities/asistencia.dart';
import '../../domain/entities/consulta_asistencia.dart';

class AsistenciaAdminTable extends StatelessWidget {
  const AsistenciaAdminTable({
    super.key,
    required this.items,
    required this.onDetail,
  });

  final List<ConsultaAsistencia> items;
  final ValueChanged<ConsultaAsistencia> onDetail;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.surfaceContainerLowest,
            ),
            columns: const [
              DataColumn(label: Text('Fecha')),
              DataColumn(label: Text('Estudiante')),
              DataColumn(label: Text('Asignatura')),
              DataColumn(label: Text('Periodo académico')),
              DataColumn(label: Text('Docente')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Observación')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: items
                .map((item) => DataRow(cells: [
                      DataCell(Text(_date(item.fecha))),
                      DataCell(_text(item.estudianteNombre, 190, bold: true)),
                      DataCell(_text(item.asignaturaNombre, 180)),
                      DataCell(_text(item.periodoNombre, 150)),
                      DataCell(_text(item.docenteNombre, 180)),
                      DataCell(Chip(label: Text(item.estado.databaseValue))),
                      DataCell(_text(item.observacion ?? '—', 200)),
                      DataCell(TextButton.icon(
                        key: ValueKey('ver_detalle_asistencia_${item.id}'),
                        onPressed: () => onDetail(item),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('Ver detalle'),
                      )),
                    ]))
                .toList(growable: false),
          ),
        ),
      );

  Widget _text(String value, double width, {bool bold = false}) => SizedBox(
        width: width,
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: bold ? const TextStyle(fontWeight: FontWeight.w600) : null,
        ),
      );

  String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}
