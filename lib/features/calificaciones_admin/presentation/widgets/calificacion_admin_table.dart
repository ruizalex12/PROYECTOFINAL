import 'package:flutter/material.dart';

import '../../domain/entities/consulta_calificacion.dart';

class CalificacionAdminTable extends StatelessWidget {
  const CalificacionAdminTable({
    super.key,
    required this.items,
    required this.onDetail,
  });
  final List<ConsultaCalificacion> items;
  final ValueChanged<ConsultaCalificacion> onDetail;

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
              DataColumn(label: Text('Estudiante')),
              DataColumn(label: Text('Asignatura')),
              DataColumn(label: Text('Periodo académico')),
              DataColumn(label: Text('Docente')),
              DataColumn(label: Text('Tipo de evaluación')),
              DataColumn(label: Text('Nota'), numeric: true),
              DataColumn(label: Text('Observación')),
              DataColumn(label: Text('Fecha de registro')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: items
                .map((item) => DataRow(cells: [
                      DataCell(_text(item.estudianteNombre, 180, bold: true)),
                      DataCell(_text(item.asignaturaNombre, 170)),
                      DataCell(_text(item.periodoNombre, 140)),
                      DataCell(_text(item.docenteNombre, 170)),
                      DataCell(_text(item.tipoEvaluacion, 150)),
                      DataCell(Text(_nota(item.nota))),
                      DataCell(_text(item.observacion ?? '—', 180)),
                      DataCell(Text(_date(item.fechaRegistro))),
                      DataCell(TextButton.icon(
                        key: ValueKey('ver_detalle_calificacion_${item.id}'),
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
        child: Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: bold ? const TextStyle(fontWeight: FontWeight.w600) : null),
      );

  String _nota(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
  String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}
