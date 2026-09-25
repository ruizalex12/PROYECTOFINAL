import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/route_names.dart';
import '../../../shared/layouts/admin_shell.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nombre =
        context.watch<AuthController>().profile?.nombres ?? 'Administrador';
    return AdminShell(
      selectedRoute: RouteNames.admin,
      title: 'Panel principal',
      child: SingleChildScrollView(
        padding:
            EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 18 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                    title: 'Bienvenido, $nombre',
                    subtitle:
                        'Resumen general del Sistema de Gestión Académica.'),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1000
                        ? 4
                        : constraints.maxWidth >= 560
                            ? 2
                            : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 16) / columns;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _SummaryCard(
                            width: width,
                            label: 'Estudiantes',
                            value: '—',
                            icon: Icons.school_outlined,
                            color: const Color(0xFF2878B8)),
                        _SummaryCard(
                            width: width,
                            label: 'Docentes',
                            value: '—',
                            icon: Icons.badge_outlined,
                            color: const Color(0xFF8160B5)),
                        _SummaryCard(
                            width: width,
                            label: 'Asignaturas',
                            value: 'Ver módulo',
                            icon: Icons.menu_book_outlined,
                            color: AppColors.primary,
                            onTap: () => Navigator.pushNamed(
                                context, RouteNames.adminAsignaturas)),
                        _SummaryCard(
                            width: width,
                            label: 'Periodo académico',
                            value: 'Sin configurar',
                            icon: Icons.calendar_month_outlined,
                            color: AppColors.secondary),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text('Accesos rápidos',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.pushNamed(
                        context, RouteNames.adminAsignaturas),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        children: [
                          Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.menu_book_rounded,
                                  color: AppColors.primary)),
                          const SizedBox(width: 16),
                          const Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Gestión de asignaturas',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17)),
                                SizedBox(height: 4),
                                Text(
                                    'Crear, editar, desactivar y reactivar asignaturas.',
                                    style: TextStyle(color: AppColors.muted))
                              ])),
                          const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEAF4F1),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                            child: Text(
                                'Los demás módulos están preparados en la navegación y se habilitarán progresivamente sin afectar la vertical E2.',
                                style: TextStyle(height: 1.45)))
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.width,
      required this.label,
      required this.value,
      required this.icon,
      required this.color,
      this.onTap});
  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(13)),
                      child: Icon(icon, color: color)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(label,
                            style: const TextStyle(color: AppColors.muted)),
                        const SizedBox(height: 5),
                        Text(value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 18))
                      ])),
                ],
              ),
            ),
          ),
        ),
      );
}
