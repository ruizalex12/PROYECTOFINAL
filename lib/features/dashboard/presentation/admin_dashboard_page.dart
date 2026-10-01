import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/route_names.dart';
import '../../../shared/layouts/admin_shell.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../estudiantes/domain/repositories/estudiante_repository.dart';
import '../../periodos/domain/entities/periodo_academico.dart';
import '../../periodos/domain/repositories/periodo_academico_repository.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  EstudianteRepository? _estudianteRepository;
  Future<int>? _estudiantesActivos;
  PeriodoAcademicoRepository? _periodoRepository;
  Future<List<PeriodoAcademico>>? _periodosActivos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<EstudianteRepository>();
    if (!identical(repository, _estudianteRepository)) {
      _estudianteRepository = repository;
      _estudiantesActivos = repository.contarActivos();
    }
    final periodoRepository = context.read<PeriodoAcademicoRepository>();
    if (!identical(periodoRepository, _periodoRepository)) {
      _periodoRepository = periodoRepository;
      _periodosActivos = periodoRepository.listarActivos();
    }
  }

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
                        FutureBuilder<int>(
                          future: _estudiantesActivos,
                          builder: (context, snapshot) => _SummaryCard(
                            width: width,
                            label: 'Estudiantes activos',
                            value: snapshot.hasData ? '${snapshot.data}' : '—',
                            icon: Icons.school_outlined,
                            color: const Color(0xFF2878B8),
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.adminEstudiantes,
                            ),
                          ),
                        ),
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
                        FutureBuilder<List<PeriodoAcademico>>(
                          future: _periodosActivos,
                          builder: (context, snapshot) => _SummaryCard(
                            width: width,
                            label: 'Periodo académico',
                            value: _periodoValue(snapshot.data),
                            icon: Icons.calendar_month_outlined,
                            color: AppColors.secondary,
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.adminPeriodos,
                            ),
                          ),
                        ),
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
                const SizedBox(height: 14),
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.pushNamed(
                      context,
                      RouteNames.adminAsignaciones,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(22),
                      child: Row(
                        children: [
                          Icon(
                            Icons.assignment_ind_outlined,
                            color: AppColors.primary,
                            size: 34,
                          ),
                          SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Asignación docente',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Relacionar docentes con asignaturas y periodos académicos.',
                                  style: TextStyle(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primary,
                          ),
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

  String _periodoValue(List<PeriodoAcademico>? periodos) {
    if (periodos == null) return '—';
    if (periodos.isEmpty) return 'Sin periodo activo';
    if (periodos.length == 1) return periodos.single.nombre;
    return '${periodos.length} periodos activos';
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
