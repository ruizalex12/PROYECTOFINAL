import 'package:flutter/material.dart';

import '../../domain/entities/consulta_asistencia.dart';

class AsistenciaAdminSummaryCards extends StatelessWidget {
  const AsistenciaAdminSummaryCards({super.key, required this.summary});

  final AsistenciaAdminSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total de registros', summary.total, Icons.list_alt_rounded),
      ('Presentes', summary.presentes, Icons.check_circle_outline),
      ('Ausentes', summary.ausentes, Icons.cancel_outlined),
      ('Licencias', summary.licencias, Icons.event_busy_outlined),
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
                              Text('${item.$2}',
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
}
