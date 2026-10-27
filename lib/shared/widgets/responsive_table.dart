import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ResponsiveTableColumn {
  const ResponsiveTableColumn(this.label,
      {this.flex = 1, this.alignment = Alignment.centerLeft});

  final String label;
  final double flex;
  final Alignment alignment;
}

class ResponsiveTable extends StatefulWidget {
  const ResponsiveTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minimumWidth = 900,
  });

  final List<ResponsiveTableColumn> columns;
  final List<List<Widget>> rows;
  final double minimumWidth;

  @override
  State<ResponsiveTable> createState() => _ResponsiveTableState();
}

class _ResponsiveTableState extends State<ResponsiveTable> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.rows.every((row) => row.length == widget.columns.length));
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = dark ? Colors.white12 : AppColors.border;
    final headerColor =
        dark ? scheme.surfaceContainerHighest : const Color(0xFFF7F9F8);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(builder: (context, constraints) {
        final width = math.max(constraints.maxWidth, widget.minimumWidth);
        return Scrollbar(
          controller: _horizontalController,
          thumbVisibility: width > constraints.maxWidth,
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.bottom,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  for (var i = 0; i < widget.columns.length; i++)
                    i: FlexColumnWidth(widget.columns[i].flex),
                },
                border: TableBorder(
                  horizontalInside: BorderSide(color: borderColor),
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: headerColor),
                    children: [
                      for (final column in widget.columns)
                        _Cell(
                          minimumHeight: 52,
                          alignment: column.alignment,
                          child: Text(column.label,
                              style: TextStyle(
                                  color:
                                      dark ? scheme.onSurface : AppColors.ink,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ),
                    ],
                  ),
                  for (final row in widget.rows)
                    TableRow(
                      decoration: BoxDecoration(color: scheme.surface),
                      children: [
                        for (var i = 0; i < row.length; i++)
                          _Cell(
                            minimumHeight: 64,
                            alignment: widget.columns[i].alignment,
                            child: row[i],
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(
      {required this.child,
      required this.minimumHeight,
      required this.alignment});

  final Widget child;
  final double minimumHeight;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(minHeight: minimumHeight),
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: child,
      );
}
