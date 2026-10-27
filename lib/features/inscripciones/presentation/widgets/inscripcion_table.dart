import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/responsive_table.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/inscripcion.dart';

class InscripcionTable extends StatelessWidget {
  const InscripcionTable(
      {super.key,
      required this.items,
      required this.onEdit,
      required this.onToggle});
  final List<Inscripcion> items;
  final ValueChanged<Inscripcion> onEdit, onToggle;

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context) => ResponsiveTable(
        minimumWidth: 1000,
        columns: const [
          ResponsiveTableColumn('Estudiante', flex: 2.2),
          ResponsiveTableColumn('Asignatura', flex: 2.5),
          ResponsiveTableColumn('Fecha inscripción', flex: 1.45),
          ResponsiveTableColumn('Estado', flex: 1.25),
          ResponsiveTableColumn('Acciones',
              flex: 2.1, alignment: Alignment.center),
        ],
        rows: items
            .map((item) => <Widget>[
                  _text(item.estudianteNombre, bold: true),
                  _text('${item.asignaturaCodigo} · ${item.asignaturaNombre}'),
                  Text(_date(item.fechaInscripcion)),
                  StatusBadge(active: item.estado),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                            onPressed: () => onEdit(item),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Editar')),
                        TextButton.icon(
                            onPressed: () => onToggle(item),
                            icon: Icon(
                                item.estado
                                    ? Icons.block_outlined
                                    : Icons.check_circle_outline,
                                size: 18,
                                color: item.estado
                                    ? AppColors.danger
                                    : AppColors.success),
                            label:
                                Text(item.estado ? 'Desactivar' : 'Reactivar')),
                      ]),
                ])
            .toList(growable: false),
      );

  Widget _text(String value, {bool bold = false}) => Text(value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: bold ? const TextStyle(fontWeight: FontWeight.w600) : null);
}
