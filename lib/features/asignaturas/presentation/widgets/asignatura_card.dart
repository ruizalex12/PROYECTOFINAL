import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/asignatura.dart';

class AsignaturaCard extends StatelessWidget {
  const AsignaturaCard({
    super.key,
    required this.asignatura,
    required this.onEdit,
    required this.onToggle,
  });

  final Asignatura asignatura;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      asignatura.codigo,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  StatusBadge(active: asignatura.estado),
                ],
              ),
              Text(
                asignatura.nombre,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(asignatura.descripcion ?? 'Sin descripción',
                  style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: onToggle,
                    icon: Icon(
                      asignatura.estado
                          ? Icons.block_outlined
                          : Icons.check_circle_outline,
                    ),
                    label: Text(asignatura.estado ? 'Desactivar' : 'Reactivar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
