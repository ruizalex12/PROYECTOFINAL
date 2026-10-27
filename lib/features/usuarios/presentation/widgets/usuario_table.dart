import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/responsive_table.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/usuario.dart';

class UsuarioTable extends StatelessWidget {
  const UsuarioTable(
      {super.key,
      required this.items,
      required this.onEdit,
      required this.onToggle});
  final List<Usuario> items;
  final ValueChanged<Usuario> onEdit, onToggle;
  @override
  Widget build(BuildContext context) => ResponsiveTable(
      minimumWidth: 1150,
      columns: const [
        ResponsiveTableColumn('Nombre completo', flex: 2),
        ResponsiveTableColumn('Correo', flex: 2.3),
        ResponsiveTableColumn('CI', flex: 1.1),
        ResponsiveTableColumn('Rol', flex: 1.15),
        ResponsiveTableColumn('Estado', flex: 1.4),
        ResponsiveTableColumn('Fecha de registro', flex: 1.4),
        ResponsiveTableColumn('Acciones',
            flex: 1.25, alignment: Alignment.center),
      ],
      rows: items
          .map((item) => <Widget>[
                _text(item.nombreCompleto, bold: true),
                _text(item.correo),
                _text(item.ci),
                Chip(label: Text(item.rol.label)),
                StatusBadge(active: item.estado),
                Text(_date(item.fechaRegistro)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () => onEdit(item),
                          tooltip: 'Editar usuario',
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          visualDensity: VisualDensity.compact),
                      IconButton(
                          onPressed: () => onToggle(item),
                          tooltip: item.estado
                              ? 'Desactivar usuario'
                              : 'Reactivar usuario',
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
  String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}
