import 'package:flutter/material.dart';

enum PeriodoEstadoFiltro { todos, activos, inactivos }

extension PeriodoEstadoFiltroValue on PeriodoEstadoFiltro {
  bool? get value => switch (this) {
        PeriodoEstadoFiltro.todos => null,
        PeriodoEstadoFiltro.activos => true,
        PeriodoEstadoFiltro.inactivos => false,
      };
}

class PeriodoAcademicoFilters extends StatelessWidget {
  const PeriodoAcademicoFilters({
    super.key,
    required this.searchController,
    required this.estado,
    required this.onEstado,
    required this.onBuscar,
    required this.onLimpiar,
  });

  final TextEditingController searchController;
  final PeriodoEstadoFiltro estado;
  final ValueChanged<PeriodoEstadoFiltro> onEstado;
  final VoidCallback onBuscar;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 650;
              final search = TextField(
                controller: searchController,
                onSubmitted: (_) => onBuscar(),
                decoration: const InputDecoration(
                  labelText: 'Buscar periodo',
                  hintText: 'Nombre del periodo académico',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              );
              final filter = SizedBox(
                width: compact ? double.infinity : 190,
                child: DropdownButtonFormField<PeriodoEstadoFiltro>(
                  initialValue: estado,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(
                      value: PeriodoEstadoFiltro.todos,
                      child: Text('Todos'),
                    ),
                    DropdownMenuItem(
                      value: PeriodoEstadoFiltro.activos,
                      child: Text('Activos'),
                    ),
                    DropdownMenuItem(
                      value: PeriodoEstadoFiltro.inactivos,
                      child: Text('Inactivos'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) onEstado(value);
                  },
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    search,
                    const SizedBox(height: 12),
                    filter,
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 12),
                  filter,
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
        ),
      );
}
