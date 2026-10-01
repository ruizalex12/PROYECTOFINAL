import 'package:flutter/material.dart';

import '../../domain/entities/usuario.dart';

enum UsuarioRolFiltro { todos, administrador, docente }

enum UsuarioEstadoFiltro { todos, activos, inactivos }

extension UsuarioRolFiltroValue on UsuarioRolFiltro {
  UsuarioRol? get value => switch (this) {
        UsuarioRolFiltro.todos => null,
        UsuarioRolFiltro.administrador => UsuarioRol.administrador,
        UsuarioRolFiltro.docente => UsuarioRol.docente,
      };
}

extension UsuarioEstadoFiltroValue on UsuarioEstadoFiltro {
  bool? get value => switch (this) {
        UsuarioEstadoFiltro.todos => null,
        UsuarioEstadoFiltro.activos => true,
        UsuarioEstadoFiltro.inactivos => false,
      };
}

class UsuarioFilters extends StatelessWidget {
  const UsuarioFilters({
    super.key,
    required this.searchController,
    required this.rol,
    required this.estado,
    required this.onRol,
    required this.onEstado,
    required this.onBuscar,
    required this.onLimpiar,
  });

  final TextEditingController searchController;
  final UsuarioRolFiltro rol;
  final UsuarioEstadoFiltro estado;
  final ValueChanged<UsuarioRolFiltro> onRol;
  final ValueChanged<UsuarioEstadoFiltro> onEstado;
  final VoidCallback onBuscar;
  final VoidCallback onLimpiar;

  UsuarioRol? get rolValue => rol.value;
  bool? get estadoValue => estado.value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 820;
              final controls = <Widget>[
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (_) => onBuscar(),
                    decoration: const InputDecoration(
                      labelText: 'Buscar usuario',
                      hintText: 'Nombres, apellidos, CI o correo',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 12, height: 12),
                Expanded(child: _rolDropdown()),
                const SizedBox(width: 12, height: 12),
                Expanded(child: _estadoDropdown()),
              ];
              final actions = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                      onPressed: onBuscar, child: const Text('Buscar')),
                  const SizedBox(width: 8),
                  TextButton(
                      onPressed: onLimpiar, child: const Text('Limpiar')),
                ],
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: searchController,
                      onSubmitted: (_) => onBuscar(),
                      decoration: const InputDecoration(
                        labelText: 'Buscar usuario',
                        hintText: 'Nombres, apellidos, CI o correo',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _rolDropdown(),
                    const SizedBox(height: 12),
                    _estadoDropdown(),
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                );
              }
              return Row(
                  children: [...controls, const SizedBox(width: 12), actions]);
            },
          ),
        ),
      );

  Widget _rolDropdown() => DropdownButtonFormField<UsuarioRolFiltro>(
        initialValue: rol,
        decoration: const InputDecoration(labelText: 'Rol'),
        items: const [
          DropdownMenuItem(value: UsuarioRolFiltro.todos, child: Text('Todos')),
          DropdownMenuItem(
              value: UsuarioRolFiltro.administrador,
              child: Text('Administrador')),
          DropdownMenuItem(
              value: UsuarioRolFiltro.docente, child: Text('Docente')),
        ],
        onChanged: (value) {
          if (value != null) onRol(value);
        },
      );

  Widget _estadoDropdown() => DropdownButtonFormField<UsuarioEstadoFiltro>(
        initialValue: estado,
        decoration: const InputDecoration(labelText: 'Estado'),
        items: const [
          DropdownMenuItem(
              value: UsuarioEstadoFiltro.todos, child: Text('Todos')),
          DropdownMenuItem(
              value: UsuarioEstadoFiltro.activos, child: Text('Activos')),
          DropdownMenuItem(
              value: UsuarioEstadoFiltro.inactivos, child: Text('Inactivos')),
        ],
        onChanged: (value) {
          if (value != null) onEstado(value);
        },
      );
}
