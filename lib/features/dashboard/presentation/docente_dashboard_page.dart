import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/route_names.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class DocenteDashboardPage extends StatelessWidget {
  const DocenteDashboardPage({super.key});

  Future<void> _cerrarSesion(
    BuildContext context,
    AuthController auth,
  ) async {
    await auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final nombre = auth.profile?.nombreCompleto ?? 'Docente';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel docente',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context, auth),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 600 ? 18 : 28,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenido, $nombre',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Consulte desde aquí su actividad académica.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Resumen',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 760 ? 3 : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 16) / columns;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _DashboardCard(
                          width: width,
                          title: 'Mis asignaturas',
                          subtitle: 'Próximamente',
                          icon: Icons.menu_book_outlined,
                          color: AppColors.primary,
                        ),
                        _DashboardCard(
                          width: width,
                          title: 'Asistencia',
                          subtitle: 'Próximamente',
                          icon: Icons.fact_check_outlined,
                          color: const Color(0xFF2878B8),
                        ),
                        _DashboardCard(
                          width: width,
                          title: 'Calificaciones',
                          subtitle: 'Próximamente',
                          icon: Icons.grading_outlined,
                          color: AppColors.secondary,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Los módulos docentes se habilitarán progresivamente.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final double width;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
