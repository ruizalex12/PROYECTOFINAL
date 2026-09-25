import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/asignatura.dart';

class AsignaturaTable extends StatelessWidget {
  const AsignaturaTable({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onToggle,
  });

  final List<Asignatura> items;
  final ValueChanged<Asignatura> onEdit;
  final ValueChanged<Asignatura> onToggle;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF0F5F3)),
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.ink),
              dataRowMinHeight: 62,
              dataRowMaxHeight: 72,
              columnSpacing: 34,
              columns: const [
                DataColumn(label: Text('Codigo')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Descripcion')),
                DataColumn(label: Text('Estado')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: items.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item.codigo)),
                  DataCell(Text(item.nombre)),
                  DataCell(
                    SizedBox(
                      width: 280,
                      child: Text(item.descripcion ?? 'Sin descripcion'),
                    ),
                  ),
                  DataCell(StatusBadge(active: item.estado)),
                  DataCell(
                    Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          onPressed: () => onEdit(item),
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.primary),
                        ),
                        IconButton(
                          tooltip: item.estado ? 'Desactivar' : 'Activar',
                          onPressed: () => onToggle(item),
                          icon: Icon(
                            item.estado
                                ? Icons.block_outlined
                                : Icons.check_circle_outline,
                            color: item.estado
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      );
}
