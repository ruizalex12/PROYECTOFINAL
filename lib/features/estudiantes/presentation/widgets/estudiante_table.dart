import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/estudiante.dart';

class EstudianteTable extends StatelessWidget {
  const EstudianteTable({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onToggle,
  });

  final List<Estudiante> items;
  final ValueChanged<Estudiante> onEdit;
  final ValueChanged<Estudiante> onToggle;

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
              DataColumn(label: Text('Código')),
              DataColumn(label: Text('Estudiante')),
              DataColumn(label: Text('CI')),
              DataColumn(label: Text('Teléfono')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: items
                .map(
                  (item) => DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(item.codigo ?? '—'),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 220,
                          child: Text(
                            item.nombreCompleto,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataCell(SizedBox(width: 110, child: Text(item.ci))),
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: Text(item.telefono ?? '—'),
                        ),
                      ),
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
}
