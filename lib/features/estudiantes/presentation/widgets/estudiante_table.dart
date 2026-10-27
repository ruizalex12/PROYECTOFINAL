import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/responsive_table.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/estudiante.dart';

class EstudianteTable extends StatelessWidget {
  const EstudianteTable(
      {super.key,
      required this.items,
      required this.onEdit,
      required this.onToggle});
  final List<Estudiante> items;
  final ValueChanged<Estudiante> onEdit, onToggle;
  @override
  Widget build(BuildContext context) => ResponsiveTable(
      minimumWidth: 1000,
      columns: const [
        ResponsiveTableColumn('Código', flex: 1.1),
        ResponsiveTableColumn('Estudiante', flex: 2.3),
        ResponsiveTableColumn('CI', flex: 1.15),
        ResponsiveTableColumn('Teléfono', flex: 1.2),
        ResponsiveTableColumn('Estado', flex: 1.35),
        ResponsiveTableColumn('Acciones',
            flex: 1.35, alignment: Alignment.center),
      ],
      rows: items
          .map((item) => <Widget>[
                Text(item.codigo ?? '—'),
                Text(item.nombreCompleto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(item.ci),
                Text(item.telefono ?? '—'),
                StatusBadge(active: item.estado),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () => onEdit(item),
                          tooltip: 'Editar estudiante',
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          visualDensity: VisualDensity.compact),
                      IconButton(
                          onPressed: () => onToggle(item),
                          tooltip: item.estado
                              ? 'Desactivar estudiante'
                              : 'Reactivar estudiante',
                          icon: Icon(
                              item.estado
                                  ? Icons.block_outlined
                                  : Icons.check_circle_outline,
                              size: 18,
                              color: item.estado
                                  ? AppColors.danger
                                  : AppColors.success),
                          visualDensity: VisualDensity.compact),
                    ]),
              ])
          .toList(growable: false));
}
