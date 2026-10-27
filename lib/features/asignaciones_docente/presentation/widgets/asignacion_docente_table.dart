import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/responsive_table.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/asignacion_docente.dart';

class AsignacionDocenteTable extends StatelessWidget {
  const AsignacionDocenteTable(
      {super.key,
      required this.items,
      required this.onEdit,
      required this.onToggle});
  final List<AsignacionDocente> items;
  final ValueChanged<AsignacionDocente> onEdit, onToggle;
  @override
  Widget build(BuildContext context) => ResponsiveTable(
      minimumWidth: 1000,
      columns: const [
        ResponsiveTableColumn('Docente', flex: 2.3),
        ResponsiveTableColumn('Asignatura', flex: 2.5),
        ResponsiveTableColumn('Periodo', flex: 1.6),
        ResponsiveTableColumn('Estado', flex: 1.1),
        ResponsiveTableColumn('Acciones',
            flex: 2.1, alignment: Alignment.center),
      ],
      rows: items
          .map((item) => <Widget>[
                Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.docenteNombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(item.docenteCorreo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12))
                    ]),
                Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.asignatura.codigo,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                      Text(item.asignatura.nombre,
                          maxLines: 1, overflow: TextOverflow.ellipsis)
                    ]),
                Text(item.periodo.nombre),
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
                              size: 18),
                          label:
                              Text(item.estado ? 'Desactivar' : 'Reactivar')),
                    ]),
              ])
          .toList(growable: false));
}
