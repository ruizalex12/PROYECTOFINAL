import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/academic_module.dart';
import '../models/academic_entities.dart';
import '../services/academic_service.dart';
import 'academic_module_screen.dart';
import 'settings_screen.dart';
import 'assignment_screen.dart';
import 'enrollment_screen.dart';
import 'reports_screen.dart';
import 'user_roles_screen.dart';

class AcademicDashboardScreen extends StatefulWidget {
  const AcademicDashboardScreen({super.key, this.profile, this.onDemoLogout});
  final Profile? profile;
  final VoidCallback? onDemoLogout;
  @override
  State<AcademicDashboardScreen> createState() => _AcademicDashboardState();
}

class _AcademicDashboardState extends State<AcademicDashboardScreen> {
  late Future<Map<String, int>> counts;
  @override
  void initState() {
    super.initState();
    counts = Future.value({});
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  void _reload() {
    final useSupabase = context.read<AppConfig>().useSupabase;
    setState(() =>
        counts = AcademicService(useSupabase: useSupabase).dashboardCounts());
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.school_rounded),
          SizedBox(width: 10),
          Text('EduGestión 360')
        ]),
        actions: [
          IconButton(
              tooltip: 'Preferencias',
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
              icon: const Icon(Icons.settings_outlined)),
          IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: () => config.useSupabase
                  ? Supabase.instance.client.auth.signOut()
                  : widget.onDemoLogout?.call(),
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Panel académico',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Resumen general y accesos de administración'),
            const SizedBox(height: 20),
            FutureBuilder<Map<String, int>>(
              future: counts,
              builder: (context, snapshot) {
                final data = snapshot.data ?? {};
                return Wrap(spacing: 12, runSpacing: 12, children: [
                  _Stat('Estudiantes', data['estudiantes'] ?? 0,
                      Icons.groups_rounded, const Color(0xFF3157D5)),
                  _Stat('Docentes', data['docentes'] ?? 0,
                      Icons.co_present_rounded, const Color(0xFF00897B)),
                  _Stat('Materias', data['materias'] ?? 0,
                      Icons.menu_book_rounded, const Color(0xFFF57C00)),
                  _Stat('Cursos', data['cursos'] ?? 0, Icons.class_rounded,
                      const Color(0xFF8E44AD)),
                ]);
              },
            ),
            const SizedBox(height: 28),
            Text('Módulos de gestión',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, children: [
              FilledButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EnrollmentScreen())),
                  icon: const Icon(Icons.how_to_reg),
                  label: const Text('Matricular estudiante')),
              FilledButton.tonalIcon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AssignmentScreen())),
                  icon: const Icon(Icons.assignment_ind),
                  label: const Text('Asignar docente')),
              OutlinedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ReportsScreen())),
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Reportes')),
              OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UserRolesScreen())),
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text('Usuarios y roles')),
            ]),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 310,
                  mainAxisExtent: 150,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12),
              itemCount: academicModules.length,
              itemBuilder: (context, index) {
                final module = academicModules[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AcademicModuleScreen(module: module)))
                        .then((_) => _reload()),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(module.icon,
                                size: 34,
                                color: Theme.of(context).colorScheme.primary),
                            const Spacer(),
                            Text(module.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const Text('Consultar, registrar y actualizar'),
                          ]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.icon, this.color);
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 220,
        height: 105,
        child: Card(
          color: color.withValues(alpha: .10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  child: Icon(icon)),
              const SizedBox(width: 14),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$value',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(label)
                  ]),
            ]),
          ),
        ),
      );
}
