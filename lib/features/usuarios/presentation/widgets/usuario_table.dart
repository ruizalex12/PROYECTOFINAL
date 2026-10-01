import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/usuario.dart';

class UsuarioTable extends StatelessWidget {
  const UsuarioTable({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onToggle,
  });

  final List<Usuario> items;
  final ValueChanged<Usuario> onEdit;
  final ValueChanged<Usuario> onToggle;

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
              DataColumn(label: Text('Nombre completo')),
              DataColumn(label: Text('Correo')),
              DataColumn(label: Text('CI')),
              DataColumn(label: Text('Rol')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Fecha de registro')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: items.map((item) => _row(item)).toList(growable: false),
          ),
        ),
      );

  DataRow _row(Usuario item) => DataRow(cells: [
        DataCell(_text(item.nombreCompleto, 190, bold: true)),
        DataCell(_text(item.correo, 220)),
        DataCell(_text(item.ci, 100)),
        DataCell(Chip(label: Text(item.rol.label))),
        DataCell(StatusBadge(active: item.estado)),
        DataCell(Text(_date(item.fechaRegistro))),
        DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
          TextButton.icon(
            onPressed: () => onEdit(item),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar'),
          ),
          TextButton.icon(
            onPressed: () => onToggle(item),
            icon: Icon(
              item.estado ? Icons.block_outlined : Icons.check_circle_outline,
              size: 18,
              color: item.estado ? AppColors.danger : AppColors.success,
            ),
            label: Text(item.estado ? 'Desactivar' : 'Reactivar'),
          ),
        ])),
      ]);

  Widget _text(String value, double width, {bool bold = false}) => SizedBox(
        width: width,
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: bold ? const TextStyle(fontWeight: FontWeight.w600) : null,
        ),
      );

  String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}
