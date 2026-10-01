import 'dart:math' as math;

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

  static const double _minimumTableWidth = 900;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = dark ? Colors.white12 : AppColors.border;
    final headerColor =
        dark ? colorScheme.surfaceContainerHighest : const Color(0xFFF7F9F8);
    final headerTextColor = dark ? colorScheme.onSurface : AppColors.ink;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableWidth = math.max(
            constraints.maxWidth,
            _minimumTableWidth,
          );

          return Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FlexColumnWidth(1.15),
                    1: FlexColumnWidth(2.1),
                    2: FlexColumnWidth(3.2),
                    3: FlexColumnWidth(1.25),
                    4: FlexColumnWidth(1.25),
                  },
                  border: TableBorder(
                    horizontalInside: BorderSide(color: borderColor),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: headerColor),
                      children: [
                        _HeaderCell(
                          label: 'Código',
                          color: headerTextColor,
                        ),
                        _HeaderCell(
                          label: 'Nombre',
                          color: headerTextColor,
                        ),
                        _HeaderCell(
                          label: 'Descripción',
                          color: headerTextColor,
                        ),
                        _HeaderCell(
                          label: 'Estado',
                          color: headerTextColor,
                        ),
                        _HeaderCell(
                          label: 'Acciones',
                          color: headerTextColor,
                          alignment: Alignment.center,
                        ),
                      ],
                    ),
                    for (final item in items)
                      TableRow(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                        ),
                        children: [
                          _BodyCell(child: Text(item.codigo)),
                          _BodyCell(
                            child: Text(
                              item.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _BodyCell(
                            child: Text(
                              item.descripcion ?? 'Sin descripción',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _BodyCell(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: StatusBadge(active: item.estado),
                            ),
                          ),
                          _BodyCell(
                            horizontalPadding: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  onPressed: () => onEdit(item),
                                  visualDensity: VisualDensity.compact,
                                  iconSize: 19,
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip:
                                      item.estado ? 'Desactivar' : 'Activar',
                                  onPressed: () => onToggle(item),
                                  visualDensity: VisualDensity.compact,
                                  iconSize: 19,
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
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.color,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 52),
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      );
}

class _BodyCell extends StatelessWidget {
  const _BodyCell({
    required this.child,
    this.horizontalPadding = 16,
  });

  final Widget child;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 64),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 10,
        ),
        child: child,
      );
}
