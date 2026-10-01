import 'package:flutter/material.dart';

import '../../domain/entities/consulta_calificacion.dart';

class CalificacionAdminSummaryCards extends StatelessWidget {
  const CalificacionAdminSummaryCards({super.key, required this.summary});
  final CalificacionAdminSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total de calificaciones', '${summary.total}', Icons.list_alt_rounded),
      ('Promedio general', _nota(summary.promedio), Icons.functions_rounded),
      ('Nota mínima', _nota(summary.notaMinima), Icons.south_rounded),
      ('Nota máxima', _nota(summary.notaMaxima), Icons.north_rounded),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth >= 800
          ? (constraints.maxWidth - 36) / 4
          : (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: items
            .map((item) => SizedBox(
                  width: width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        Icon(item.$3),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.$2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800)),
                              Text(item.$1),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ))
            .toList(growable: false),
      );
    });
  }

  String _nota(double? value) {
    if (value == null) return '—';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}
