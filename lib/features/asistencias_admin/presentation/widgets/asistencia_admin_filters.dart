import 'package:flutter/material.dart';

import '../../../asistencia/domain/entities/asistencia.dart';
import '../../domain/entities/consulta_asistencia.dart';

class AsistenciaAdminFilters extends StatelessWidget {
  const AsistenciaAdminFilters({
    super.key,
    required this.searchController,
    required this.options,
    required this.periodoId,
    required this.asignaturaId,
    required this.docenteId,
    required this.estado,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.onPeriodo,
    required this.onAsignatura,
    required this.onDocente,
    required this.onEstado,
    required this.onFechaDesde,
    required this.onFechaHasta,
    required this.onBuscar,
    required this.onLimpiar,
  });

  final TextEditingController searchController;
  final AsistenciaAdminOptions options;
  final int? periodoId;
  final int? asignaturaId;
  final String? docenteId;
  final EstadoAsistencia? estado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final ValueChanged<int?> onPeriodo;
  final ValueChanged<int?> onAsignatura;
  final ValueChanged<String?> onDocente;
  final ValueChanged<EstadoAsistencia?> onEstado;
  final ValueChanged<DateTime?> onFechaDesde;
  final ValueChanged<DateTime?> onFechaHasta;
  final VoidCallback onBuscar;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(
              controller: searchController,
              onSubmitted: (_) => onBuscar(),
              decoration: const InputDecoration(
                labelText: 'Buscar',
                hintText: 'Estudiante, CI/código, asignatura o docente',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth >= 900
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth >= 560
                      ? (constraints.maxWidth - 12) / 2
                      : constraints.maxWidth;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                SizedBox(
                  width: width,
                  child: _intDropdown(
                    label: 'Periodo académico',
                    value: periodoId,
                    options: options.periodos,
                    onChanged: onPeriodo,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _intDropdown(
                    label: 'Asignatura',
                    value: asignaturaId,
                    options: options.asignaturas,
                    onChanged: onAsignatura,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: DropdownButtonFormField<String?>(
                    initialValue: docenteId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Docente'),
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null, child: Text('Todos')),
                      ...options.docentes
                          .map((item) => DropdownMenuItem<String?>(
                                value: item.id,
                                child: Text(item.label,
                                    overflow: TextOverflow.ellipsis),
                              )),
                    ],
                    onChanged: onDocente,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: DropdownButtonFormField<EstadoAsistencia?>(
                    initialValue: estado,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: [
                      const DropdownMenuItem<EstadoAsistencia?>(
                          value: null, child: Text('Todos')),
                      ...EstadoAsistencia.values.map(
                        (item) => DropdownMenuItem<EstadoAsistencia?>(
                          value: item,
                          child: Text(item.label),
                        ),
                      ),
                    ],
                    onChanged: onEstado,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _DateFilter(
                    label: 'Fecha desde',
                    value: fechaDesde,
                    onChanged: onFechaDesde,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _DateFilter(
                    label: 'Fecha hasta',
                    value: fechaHasta,
                    onChanged: onFechaHasta,
                  ),
                ),
              ]);
            }),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton.icon(
                key: const Key('limpiar_filtros_asistencia'),
                onPressed: onLimpiar,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Limpiar filtros'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onBuscar,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Consultar'),
              ),
            ]),
          ]),
        ),
      );

  Widget _intDropdown({
    required String label,
    required int? value,
    required List<AsistenciaAdminOption<int>> options,
    required ValueChanged<int?> onChanged,
  }) =>
      DropdownButtonFormField<int?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('Todos')),
          ...options.map((item) => DropdownMenuItem<int?>(
                value: item.id,
                child: Text(item.label, overflow: TextOverflow.ellipsis),
              )),
        ],
        onChanged: onChanged,
      );
}

class _DateFilter extends StatelessWidget {
  const _DateFilter({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () async {
          final selected = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (selected != null) onChanged(selected);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: value == null
                ? const Icon(Icons.calendar_today_outlined)
                : IconButton(
                    onPressed: () => onChanged(null),
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
          child: Text(value == null ? 'Todas' : _date(value!)),
        ),
      );

  String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
