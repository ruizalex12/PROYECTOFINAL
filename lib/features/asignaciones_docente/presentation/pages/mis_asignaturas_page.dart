import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/app_states.dart';
import '../controllers/mis_asignaturas_controller.dart';
import '../widgets/asignacion_docente_card.dart';

class MisAsignaturasPage extends StatefulWidget {
  const MisAsignaturasPage({super.key});

  @override
  State<MisAsignaturasPage> createState() => _MisAsignaturasPageState();
}

class _MisAsignaturasPageState extends State<MisAsignaturasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MisAsignaturasController>().cargar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MisAsignaturasController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Mis asignaturas')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (controller.state) {
            MisAsignaturasState.loading => const AppLoadingState(
                message: 'Cargando sus asignaturas...',
              ),
            MisAsignaturasState.empty => const AppEmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No tiene asignaturas activas.',
                message: 'Consulte con el administrador académico.',
              ),
            MisAsignaturasState.error => AppErrorState(
                message: controller.errorMessage ??
                    'No fue posible cargar sus asignaturas.',
                onRetry: controller.cargar,
              ),
            MisAsignaturasState.data => RefreshIndicator(
                onRefresh: controller.cargar,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final asignacion = controller.items[index];
                    return AsignacionDocenteCard(
                      asignacion: asignacion,
                      onTap: () => Navigator.pushNamed(
                        context,
                        RouteNames.docenteEstudiantes(asignacion.id),
                        arguments: asignacion,
                      ),
                    );
                  },
                ),
              ),
          },
        ),
      ),
    );
  }
}
