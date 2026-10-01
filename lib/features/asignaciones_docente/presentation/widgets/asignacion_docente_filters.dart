import 'package:flutter/material.dart';

import '../../domain/entities/asignacion_docente.dart';

enum AsignacionEstadoFiltro { todos, activas, inactivas }

class AsignacionDocenteFilters extends StatelessWidget {
  const AsignacionDocenteFilters({
    super.key,
    required this.searchController,
    required this.items,
    required this.docenteId,
    required this.asignaturaId,
    required this.periodoId,
    required this.estado,
    required this.onDocente,
    required this.onAsignatura,
    required this.onPeriodo,
    required this.onEstado,
    required this.onBuscar,
    required this.onLimpiar,
  });

  final TextEditingController searchController;
  final List<AsignacionDocente> items;
  final String? docenteId;
  final int? asignaturaId;
  final int? periodoId;
  final AsignacionEstadoFiltro estado;
  final ValueChanged<String?> onDocente;
  final ValueChanged<int?> onAsignatura;
  final ValueChanged<int?> onPeriodo;
  final ValueChanged<AsignacionEstadoFiltro> onEstado;
  final VoidCallback onBuscar;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    final docentes = <String, String>{
      for (final item in items) item.docenteId: item.docenteNombre,
    };
    final asignaturas = <int, String>{
      for (final item in items)
        item.asignatura.id:
            '${item.asignatura.codigo} · ${item.asignatura.nombre}',
    };
    final periodos = <int, String>{
      for (final item in items) item.periodo.id: item.periodo.nombre,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 850;
            final controls = <Widget>[
              _FilterField(
                child: DropdownButtonFormField<String?>(
                  initialValue: docenteId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Docente'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...docentes.entries.map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child:
                            Text(entry.value, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: onDocente,
                ),
              ),
              _FilterField(
                child: DropdownButtonFormField<int?>(
                  initialValue: asignaturaId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Asignatura'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    ...asignaturas.entries.map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child:
                            Text(entry.value, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: onAsignatura,
                ),
              ),
              _FilterField(
                child: DropdownButtonFormField<int?>(
                  initialValue: periodoId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Periodo'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...periodos.entries.map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child:
                            Text(entry.value, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: onPeriodo,
                ),
              ),
              _FilterField(
                child: DropdownButtonFormField<AsignacionEstadoFiltro>(
                  initialValue: estado,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(
                      value: AsignacionEstadoFiltro.todos,
                      child: Text('Todos'),
                    ),
                    DropdownMenuItem(
                      value: AsignacionEstadoFiltro.activas,
                      child: Text('Activas'),
                    ),
                    DropdownMenuItem(
                      value: AsignacionEstadoFiltro.inactivas,
                      child: Text('Inactivas'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) onEstado(value);
                  },
                ),
              ),
            ];

            final search = TextField(
              controller: searchController,
              onSubmitted: (_) => onBuscar(),
              decoration: const InputDecoration(
                labelText: 'Buscar',
                hintText: 'Docente, asignatura o periodo',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            );
            final buttons = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(onPressed: onBuscar, child: const Text('Buscar')),
                const SizedBox(width: 8),
                TextButton(onPressed: onLimpiar, child: const Text('Limpiar')),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(spacing: 12, runSpacing: 12, children: controls),
                  const SizedBox(height: 12),
                  search,
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: buttons),
                ],
              );
            }
            return Column(
              children: [
                Row(
                  children: controls
                      .expand((item) =>
                          [Expanded(child: item), const SizedBox(width: 12)])
                      .toList()
                    ..removeLast(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: 12),
                    buttons,
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(width: 220, child: child);
}
