import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/responsive_table.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/docente.dart';

class DocenteTable extends StatelessWidget {
  const DocenteTable(
      {super.key,
      required this.items,
      required this.onView,
      required this.onEdit,
      required this.onToggle});
  final List<Docente> items;
  final ValueChanged<Docente> onView, onEdit, onToggle;
  @override
  Widget build(BuildContext context) => ResponsiveTable(
      minimumWidth: 1000,
      columns: const [
        ResponsiveTableColumn('Docente', flex: 2.2),
        ResponsiveTableColumn('CI', flex: 1.1),
        ResponsiveTableColumn('Especialidad', flex: 1.8),
        ResponsiveTableColumn('Teléfono', flex: 1.2),
        ResponsiveTableColumn('Estado', flex: 1.1),
        ResponsiveTableColumn('Acciones',
            flex: 1.4, alignment: Alignment.center),
      ],
      rows: items
          .map((item) => <Widget>[
                _text(item.nombreCompleto, bold: true),
                _text(item.ci),
                _text(item.especialidad ?? '—'),
                _text(item.telefono ?? '—'),
                StatusBadge(active: item.estado),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () => onView(item),
                          tooltip: 'Ver detalle del docente',
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          visualDensity: VisualDensity.compact),
                      IconButton(
                          onPressed: () => onEdit(item),
                          tooltip: 'Editar docente',
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          visualDensity: VisualDensity.compact),
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
                                  : AppColors.success),
                          visualDensity: VisualDensity.compact),
                    ]),
              ])
          .toList(growable: false));
  Widget _text(String value, {bool bold = false}) => Text(value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: bold ? const TextStyle(fontWeight: FontWeight.w600) : null);
}
