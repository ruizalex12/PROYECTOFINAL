import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/inscripcion.dart';

class InscripcionTable extends StatelessWidget {
  const InscripcionTable({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onToggle,
  });

  final List<Inscripcion> items;
  final ValueChanged<Inscripcion> onEdit;
  final ValueChanged<Inscripcion> onToggle;

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
              DataColumn(label: Text('Estudiante')),
              DataColumn(label: Text('Asignatura')),
              DataColumn(label: Text('Periodo')),
              DataColumn(label: Text('Fecha inscripción')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: items
                .map(
                  (item) => DataRow(
                    cells: [
                      DataCell(_text(item.estudianteNombre, 210)),
                      DataCell(
                        _text(
                          '${item.asignaturaCodigo} · ${item.asignaturaNombre}',
                          230,
                        ),
                      ),
                      DataCell(_text(item.periodoNombre, 150)),
                      DataCell(Text(_date(item.fechaInscripcion))),
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

  Widget _text(String value, double width) => SizedBox(
        width: width,
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
}
