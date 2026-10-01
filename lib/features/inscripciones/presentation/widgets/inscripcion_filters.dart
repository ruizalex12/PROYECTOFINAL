import 'package:flutter/material.dart';

import '../../domain/entities/inscripcion.dart';

enum InscripcionEstadoFiltro { todas, activas, inactivas }

class InscripcionFilters extends StatelessWidget {
  const InscripcionFilters({
    super.key,
    required this.searchController,
    required this.items,
    required this.estudianteId,
    required this.asignaturaId,
    required this.periodoId,
    required this.estado,
    required this.onEstudiante,
    required this.onAsignatura,
    required this.onPeriodo,
    required this.onEstado,
    required this.onBuscar,
    required this.onLimpiar,
  });

  final TextEditingController searchController;
  final List<Inscripcion> items;
  final int? estudianteId;
  final int? asignaturaId;
  final int? periodoId;
  final InscripcionEstadoFiltro estado;
  final ValueChanged<int?> onEstudiante;
  final ValueChanged<int?> onAsignatura;
  final ValueChanged<int?> onPeriodo;
  final ValueChanged<InscripcionEstadoFiltro> onEstado;
  final VoidCallback onBuscar;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    final estudiantes = <int, String>{
      for (final item in items) item.estudianteId: item.estudianteNombre,
    };
    final asignaturas = <int, String>{
      for (final item in items)
        item.asignaturaId:
            '${item.asignaturaCodigo} · ${item.asignaturaNombre}',
    };
    final periodos = <int, String>{
      for (final item in items) item.periodoId: item.periodoNombre,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _filter(
                      'Estudiante', estudianteId, estudiantes, onEstudiante),
                  _filter(
                      'Asignatura', asignaturaId, asignaturas, onAsignatura),
                  _filter('Periodo', periodoId, periodos, onPeriodo),
                  SizedBox(
                    width:
                        constraints.maxWidth < 600 ? constraints.maxWidth : 220,
                    child: DropdownButtonFormField<InscripcionEstadoFiltro>(
                      initialValue: estado,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: const [
                        DropdownMenuItem(
                          value: InscripcionEstadoFiltro.todas,
                          child: Text('Todas'),
                        ),
                        DropdownMenuItem(
                          value: InscripcionEstadoFiltro.activas,
                          child: Text('Activas'),
                        ),
                        DropdownMenuItem(
                          value: InscripcionEstadoFiltro.inactivas,
                          child: Text('Inactivas'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) onEstado(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 600;
                final search = TextField(
                  controller: searchController,
                  onSubmitted: (_) => onBuscar(),
                  decoration: const InputDecoration(
                    labelText: 'Buscar',
                    hintText: 'Estudiante, asignatura o periodo',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                );
                final actions = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: onBuscar,
                      child: const Text('Buscar'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: onLimpiar,
                      child: const Text('Limpiar'),
                    ),
                  ],
                );
                if (compact) {
                  return Column(
                    children: [
                      search,
                      const SizedBox(height: 10),
                      Align(alignment: Alignment.centerRight, child: actions),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: 12),
                    actions,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _filter(
    String label,
    int? value,
    Map<int, String> values,
    ValueChanged<int?> onChanged,
  ) =>
      SizedBox(
        width: 220,
        child: DropdownButtonFormField<int?>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(labelText: label),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos')),
            ...values.entries.map(
              (entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      );
}
