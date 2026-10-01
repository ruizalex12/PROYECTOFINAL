import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/asignacion_docente.dart';

class AsignacionDocenteTable extends StatelessWidget {
  const AsignacionDocenteTable({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onToggle,
  });

  final List<AsignacionDocente> items;
  final ValueChanged<AsignacionDocente> onEdit;
  final ValueChanged<AsignacionDocente> onToggle;

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
              DataColumn(label: Text('Asignatura')),
              DataColumn(label: Text('Periodo')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: items
                .map(
                  (item) => DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 210,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.docenteNombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                item.docenteCorreo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 230,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.asignatura.codigo,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                item.asignatura.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(Text(item.periodo.nombre)),
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
