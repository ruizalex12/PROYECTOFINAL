import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../routes/route_names.dart';
import '../widgets/app_brand.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.selectedRoute,
    required this.title,
    required this.child,
  });

  final String selectedRoute;
  final String title;
  final Widget child;

  static const _items = <_NavItem>[
    _NavItem('Dashboard', Icons.dashboard_outlined, RouteNames.admin),
    _NavItem('Usuarios', Icons.manage_accounts_outlined, null),
    _NavItem('Estudiantes', Icons.school_outlined, null),
    _NavItem('Docentes', Icons.badge_outlined, null),
    _NavItem(
        'Asignaturas', Icons.menu_book_outlined, RouteNames.adminAsignaturas),
    _NavItem('Periodos académicos', Icons.calendar_month_outlined, null),
    _NavItem('Inscripciones', Icons.app_registration_outlined, null),
    _NavItem('Asignación docente', Icons.assignment_ind_outlined, null),
    _NavItem('Asistencia', Icons.fact_check_outlined, null),
    _NavItem('Calificaciones', Icons.grading_outlined, null),
    _NavItem('Reportes', Icons.bar_chart_outlined, null),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 1050;
          final navigation = _Navigation(
            selectedRoute: selectedRoute,
            closeDrawer: !desktop,
          );
          return Scaffold(
            drawer: desktop ? null : Drawer(width: 284, child: navigation),
            body: Row(
              children: [
                if (desktop) SizedBox(width: 270, child: navigation),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(title: title, showMenu: !desktop),
                      Expanded(
                        child: ColoredBox(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.selectedRoute, required this.closeDrawer});

  final String selectedRoute;
  final bool closeDrawer;

  void _navigate(BuildContext context, _NavItem item) {
    if (closeDrawer) Navigator.pop(context);
    if (item.route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${item.label} estará disponible en una próxima etapa.')),
      );
      return;
    }
    if (item.route == selectedRoute) return;
    Navigator.pushReplacementNamed(context, item.route!);
  }

  Future<void> _signOut(BuildContext context) async {
    if (closeDrawer) Navigator.pop(context);
    await context.read<AuthController>().signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, RouteNames.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.primaryDark,
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: AppBrand(compact: true, light: true),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 4, 12, 10),
                      child: Text('MENÚ PRINCIPAL',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1)),
                    ),
                    for (final item in AdminShell._items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          dense: true,
                          selected: item.route == selectedRoute,
                          selectedTileColor:
                              Colors.white.withValues(alpha: .13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          leading: Icon(item.icon,
                              color: item.route == selectedRoute
                                  ? Colors.white
                                  : Colors.white70,
                              size: 21),
                          title: Text(item.label,
                              style: TextStyle(
                                  color: item.route == selectedRoute
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: item.route == selectedRoute
                                      ? FontWeight.w700
                                      : FontWeight.w500)),
                          onTap: () => _navigate(context, item),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  leading:
                      const Icon(Icons.logout_rounded, color: Colors.white70),
                  title: const Text('Cerrar sesión',
                      style: TextStyle(color: Colors.white70)),
                  onTap: () => _signOut(context),
                ),
              ),
            ],
          ),
        ),
      );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.showMenu});

  final String title;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthController>().profile;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (showMenu) ...[
            Builder(
                builder: (context) => IconButton(
                    onPressed: Scaffold.of(context).openDrawer,
                    icon: const Icon(Icons.menu_rounded),
                    tooltip: 'Abrir menú')),
            const SizedBox(width: 8),
          ],
          Expanded(
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800))),
          const Icon(Icons.notifications_none_rounded),
          const SizedBox(width: 18),
          CircleAvatar(
            radius: 19,
            backgroundColor: const Color(0xFFE3F1ED),
            child: Text(
              (profile?.nombres.isNotEmpty ?? false)
                  ? profile!.nombres[0].toUpperCase()
                  : 'A',
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          if (MediaQuery.sizeOf(context).width >= 700)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile?.nombreCompleto ?? 'Administrador',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const Text('Administrador',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String? route;
}
