import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../asignaciones_docente/domain/entities/asignacion_docente.dart';
import '../controllers/estudiantes_asignacion_controller.dart';

class EstudiantesAsignacionPage extends StatefulWidget {
  const EstudiantesAsignacionPage({super.key, required this.asignacion});

  final AsignacionDocente asignacion;

  @override
  State<EstudiantesAsignacionPage> createState() =>
      _EstudiantesAsignacionPageState();
}

class _EstudiantesAsignacionPageState extends State<EstudiantesAsignacionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<EstudiantesAsignacionController>().cargar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EstudiantesAsignacionController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Estudiantes')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.asignacion.asignatura.nombre,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.asignacion.periodo.nombre),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            RouteNames.docenteAsistencia(widget.asignacion.id),
                            arguments: widget.asignacion,
                          ),
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('Asistencia'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            RouteNames.docenteCalificaciones(
                              widget.asignacion.id,
                            ),
                            arguments: widget.asignacion,
                          ),
                          icon: const Icon(Icons.grading_outlined),
                          label: const Text('Calificaciones'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _body(controller)),
          ],
        ),
      ),
    );
  }

  Widget _body(EstudiantesAsignacionController controller) =>
      switch (controller.state) {
        EstudiantesAsignacionState.loading => const AppLoadingState(
            message: 'Cargando estudiantes...',
          ),
        EstudiantesAsignacionState.empty => const AppEmptyState(
            icon: Icons.groups_outlined,
            title: 'No hay estudiantes inscritos.',
            message: 'No existen inscripciones activas para esta asignatura.',
          ),
        EstudiantesAsignacionState.error => AppErrorState(
            message: controller.errorMessage ??
                'No fue posible cargar los estudiantes.',
            onRetry: controller.cargar,
          ),
        EstudiantesAsignacionState.data => RefreshIndicator(
            onRefresh: controller.cargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final estudiante = controller.items[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: CircleAvatar(
                    child: Text(estudiante.nombres[0].toUpperCase()),
                  ),
                  title: Text(estudiante.nombreCompleto),
                  subtitle: Text(
                    estudiante.codigo?.isNotEmpty == true
                        ? '${estudiante.codigo} · CI ${estudiante.ci}'
                        : 'CI ${estudiante.ci}',
                  ),
                );
              },
            ),
          ),
      };
}
