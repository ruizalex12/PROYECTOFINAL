import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/docente.dart';

class DocenteTable extends StatelessWidget {
  const DocenteTable({
    super.key,
    required this.items,
    required this.onView,
    required this.onEdit,
    required this.onToggle,
  });

  final List<Docente> items;
  final ValueChanged<Docente> onView;
  final ValueChanged<Docente> onEdit;
  final ValueChanged<Docente> onToggle;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            horizontalMargin: 20,
            columnSpacing: 24,
            headingRowColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.surfaceContainerLowest,
            ),
            columns: const [
              DataColumn(label: Text('Docente')),
              DataColumn(label: Text('CI')),
              DataColumn(label: Text('Especialidad')),
              DataColumn(label: Text('Teléfono')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: items
                .map(
                  (item) => DataRow(
                    cells: [
                      DataCell(_text(item.nombreCompleto, 210, bold: true)),
                      DataCell(_text(item.ci, 110)),
                      DataCell(_text(item.especialidad ?? '—', 180)),
                      DataCell(_text(item.telefono ?? '—', 110)),
                      DataCell(StatusBadge(active: item.estado)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => onView(item),
                              tooltip: 'Ver detalle del docente',
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 18,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            IconButton(
                              onPressed: () => onEdit(item),
                              tooltip: 'Editar docente',
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              visualDensity: VisualDensity.compact,
                            ),
                            IconButton(
                              onPressed: () => onToggle(item),
                              tooltip: item.estado
                                  ? 'Desactivar docente'
                                  : 'Reactivar docente',
                              icon: Icon(
                                item.estado
                                    ? Icons.block_outlined
                                    : Icons.check_circle_outline,
                                size: 18,
                                color: item.estado
                                    ? AppColors.danger
                                    : AppColors.success,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
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
}
