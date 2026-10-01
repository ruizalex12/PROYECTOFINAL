import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/periodo_academico.dart';

class PeriodoAcademicoTable extends StatelessWidget {
  const PeriodoAcademicoTable({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onToggle,
  });

  final List<PeriodoAcademico> items;
  final ValueChanged<PeriodoAcademico> onEdit;
  final ValueChanged<PeriodoAcademico> onToggle;

  String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';

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
              DataColumn(label: Text('Periodo')),
              DataColumn(label: Text('Fecha inicio')),
              DataColumn(label: Text('Fecha fin')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: items
                .map(
                  (item) => DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 230,
                          child: Text(
                            item.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataCell(Text(_date(item.fechaInicio))),
                      DataCell(Text(_date(item.fechaFin))),
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
