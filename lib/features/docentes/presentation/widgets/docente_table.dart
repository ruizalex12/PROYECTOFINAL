import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/docente.dart';

class DocenteTable extends StatelessWidget {
  const DocenteTable({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onToggle,
  });

  final List<Docente> items;
  final ValueChanged<Docente> onEdit;
  final ValueChanged<Docente> onToggle;

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
              DataColumn(label: Text('Docente')),
              DataColumn(label: Text('CI')),
              DataColumn(label: Text('Correo')),
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
                      DataCell(_text(item.correo, 220)),
                      DataCell(_text(item.telefono ?? '—', 110)),
                      DataCell(StatusBadge(active: item.estado)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: () => onEdit(item),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Editar'),
                            ),
                            TextButton.icon(
                              onPressed: () => onToggle(item),
                              icon: Icon(
                                item.estado
                                    ? Icons.block_outlined
                                    : Icons.check_circle_outline,
                                size: 18,
                                color: item.estado
                                    ? AppColors.danger
                                    : AppColors.success,
                              ),
                              label: Text(
                                item.estado ? 'Desactivar' : 'Reactivar',
                              ),
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
