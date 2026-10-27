import 'package:flutter/material.dart';

import '../../../../shared/widgets/responsive_table.dart';
import '../../domain/entities/consulta_calificacion.dart';

class CalificacionAdminTable extends StatelessWidget {
  const CalificacionAdminTable(
      {super.key, required this.items, required this.onDetail});
  final List<ConsultaCalificacion> items;
  final ValueChanged<ConsultaCalificacion> onDetail;

  @override
  Widget build(BuildContext context) => ResponsiveTable(
        minimumWidth: 1550,
        columns: const [
          ResponsiveTableColumn('Estudiante', flex: 1.8),
          ResponsiveTableColumn('Asignatura', flex: 1.7),
          ResponsiveTableColumn('Periodo académico', flex: 1.45),
          ResponsiveTableColumn('Docente', flex: 1.7),
          ResponsiveTableColumn('Tipo de evaluación', flex: 1.5),
          ResponsiveTableColumn('Nota', flex: .75, alignment: Alignment.center),
          ResponsiveTableColumn('Observación', flex: 1.8),
          ResponsiveTableColumn('Fecha de registro', flex: 1.35),
          ResponsiveTableColumn('Acciones',
              flex: 1.4, alignment: Alignment.center),
        ],
        rows: items
            .map((item) => <Widget>[
                  _text(item.estudianteNombre, bold: true),
                  _text(item.asignaturaNombre),
                  _text(item.periodoNombre),
                  _text(item.docenteNombre),
                  _text(item.tipoEvaluacion),
                  Text(_nota(item.nota)),
                  _text(item.observacion ?? '—'),
                  Text(_date(item.fechaRegistro)),
                  TextButton.icon(
                      key: ValueKey('ver_detalle_calificacion_${item.id}'),
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
  String _nota(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
