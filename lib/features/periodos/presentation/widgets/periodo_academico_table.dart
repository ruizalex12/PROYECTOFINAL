import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/responsive_table.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/periodo_academico.dart';

class PeriodoAcademicoTable extends StatelessWidget {
  const PeriodoAcademicoTable(
      {super.key,
      required this.items,
      required this.onEdit,
      required this.onToggle});
  final List<PeriodoAcademico> items;
  final ValueChanged<PeriodoAcademico> onEdit, onToggle;
  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  @override
  Widget build(BuildContext context) => ResponsiveTable(
          columns: const [
            ResponsiveTableColumn('Periodo', flex: 2.5),
            ResponsiveTableColumn('Fecha inicio', flex: 1.4),
            ResponsiveTableColumn('Fecha fin', flex: 1.4),
            ResponsiveTableColumn('Estado', flex: 1.2),
            ResponsiveTableColumn('Acciones',
                flex: 2.2, alignment: Alignment.center),
          ],
          rows: items
              .map((item) => <Widget>[
                    Text(item.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(_date(item.fechaInicio)),
                    Text(_date(item.fechaFin)),
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
                              label: Text(
                                  item.estado ? 'Desactivar' : 'Reactivar')),
                        ]),
                  ])
              .toList(growable: false));
}
