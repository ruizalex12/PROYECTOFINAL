import 'package:flutter/material.dart';

enum EstudianteEstadoFiltro { todos, activos, inactivos }

extension EstudianteEstadoFiltroValue on EstudianteEstadoFiltro {
  bool? get value => switch (this) {
        EstudianteEstadoFiltro.todos => null,
        EstudianteEstadoFiltro.activos => true,
        EstudianteEstadoFiltro.inactivos => false,
      };
}

class EstudianteFilters extends StatelessWidget {
  const EstudianteFilters({
    super.key,
    required this.searchController,
    required this.estado,
    required this.onEstado,
    required this.onBuscar,
    required this.onLimpiar,
  });

  final TextEditingController searchController;
  final EstudianteEstadoFiltro estado;
  final ValueChanged<EstudianteEstadoFiltro> onEstado;
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
                  labelText: 'Buscar estudiante',
                  hintText: 'Código, nombres, apellidos o CI',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              );
              final filter = SizedBox(
                width: compact ? double.infinity : 190,
                child: DropdownButtonFormField<EstudianteEstadoFiltro>(
                  initialValue: estado,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(
                      value: EstudianteEstadoFiltro.todos,
                      child: Text('Todos'),
                    ),
                    DropdownMenuItem(
                      value: EstudianteEstadoFiltro.activos,
                      child: Text('Activos'),
                    ),
                    DropdownMenuItem(
                      value: EstudianteEstadoFiltro.inactivos,
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
