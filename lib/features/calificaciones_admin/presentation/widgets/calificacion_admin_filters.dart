import 'package:flutter/material.dart';

import '../../domain/entities/consulta_calificacion.dart';

class CalificacionAdminFilters extends StatelessWidget {
  const CalificacionAdminFilters({
    super.key,
    required this.searchController,
    required this.notaMinimaController,
    required this.notaMaximaController,
    required this.options,
    required this.periodoId,
    required this.asignaturaId,
    required this.docenteId,
    required this.tipoEvaluacion,
    required this.onPeriodo,
    required this.onAsignatura,
    required this.onDocente,
    required this.onTipo,
    required this.onConsultar,
    required this.onLimpiar,
    this.validationMessage,
  });

  final TextEditingController searchController;
  final TextEditingController notaMinimaController;
  final TextEditingController notaMaximaController;
  final CalificacionAdminOptions options;
  final int? periodoId;
  final int? asignaturaId;
  final String? docenteId;
  final String? tipoEvaluacion;
  final ValueChanged<int?> onPeriodo;
  final ValueChanged<int?> onAsignatura;
  final ValueChanged<String?> onDocente;
  final ValueChanged<String?> onTipo;
  final VoidCallback onConsultar;
  final VoidCallback onLimpiar;
  final String? validationMessage;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(
              controller: searchController,
              onSubmitted: (_) => onConsultar(),
              decoration: const InputDecoration(
                labelText: 'Buscar',
                hintText:
                    'Estudiante, CI/código, asignatura, docente o evaluación',
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
                  child: _intDropdown('Periodo académico', periodoId,
                      options.periodos, onPeriodo),
                ),
                SizedBox(
                  width: width,
                  child: _intDropdown('Asignatura', asignaturaId,
                      options.asignaturas, onAsignatura),
                ),
                SizedBox(
                  width: width,
                  child: _stringDropdown(
                      'Docente', docenteId, options.docentes, onDocente),
                ),
                SizedBox(
                  width: width,
                  child: DropdownButtonFormField<String?>(
                    initialValue: tipoEvaluacion,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(labelText: 'Tipo de evaluación'),
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null, child: Text('Todos')),
                      ...options.tiposEvaluacion.map(
                        (value) => DropdownMenuItem<String?>(
                          value: value,
                          child: Text(value, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: onTipo,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: TextField(
                    controller: notaMinimaController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Nota mínima',
                      hintText: '0 a 100',
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: TextField(
                    controller: notaMaximaController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Nota máxima',
                      hintText: '0 a 100',
                    ),
                  ),
                ),
              ]);
            }),
            if (validationMessage != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(validationMessage!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton.icon(
                key: const Key('limpiar_filtros_calificacion'),
                onPressed: onLimpiar,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Limpiar filtros'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onConsultar,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Consultar'),
              ),
            ]),
          ]),
        ),
      );

  Widget _intDropdown(
    String label,
    int? value,
    List<CalificacionAdminOption<int>> options,
    ValueChanged<int?> onChanged,
  ) =>
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

  Widget _stringDropdown(
    String label,
    String? value,
    List<CalificacionAdminOption<String>> options,
    ValueChanged<String?> onChanged,
  ) =>
      DropdownButtonFormField<String?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          const DropdownMenuItem<String?>(value: null, child: Text('Todos')),
          ...options.map((item) => DropdownMenuItem<String?>(
                value: item.id,
                child: Text(item.label, overflow: TextOverflow.ellipsis),
              )),
        ],
        onChanged: onChanged,
      );
}
