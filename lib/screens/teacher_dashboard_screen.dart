import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/academic_entities.dart';
import '../services/teacher_service.dart';
import '../widgets/app_states.dart';
import '../widgets/status_banner.dart';
import 'teacher_course_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen(
      {super.key, required this.profile, this.onDemoLogout});
  final Profile profile;
  final VoidCallback? onDemoLogout;
  @override
  State<TeacherDashboardScreen> createState() => _State();
}

class _State extends State<TeacherDashboardScreen> {
  late Future<List<CourseAssignment>> future;
  TeacherService get service =>
      TeacherService(useSupabase: context.read<AppConfig>().useSupabase);
  @override
  void initState() {
    super.initState();
    future = Future.value([]);
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  Future<void> load() async {
    final courses = await service.myCourses(widget.profile.teacherId!);
    if (!mounted) return;
    setState(() {
      future = Future.value(courses);
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    return Scaffold(
        appBar: AppBar(title: const Text('Panel docente'), actions: [
          IconButton(
              onPressed: () => config.useSupabase
                  ? Supabase.instance.client.auth.signOut()
                  : widget.onDemoLogout?.call(),
              icon: const Icon(Icons.logout))
        ]),
        body: Column(children: [
          StatusBanner(demoMode: !config.useSupabase),
          Expanded(
              child: FutureBuilder<List<CourseAssignment>>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return ErrorState(
                          message: friendlyError(snapshot.error!), retry: load);
                    }
                    final rows = snapshot.data!;
                    if (rows.isEmpty) {
                      return const EmptyState(
                          icon: Icons.class_outlined,
                          title: 'No tienes cursos asignados todavía',
                          message:
                              'Cuando un administrador te asigne un curso, aparecerá aquí.');
                    }
                    return ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF071B4A),
                                Color(0xFF123A83),
                              ]),
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x26071B4A),
                                  blurRadius: 22,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(children: [
                              const CircleAvatar(
                                radius: 29,
                                backgroundColor: Color(0xFFFFD66B),
                                child: Icon(Icons.school_rounded,
                                    color: Color(0xFF071B4A), size: 31),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Hola, ${widget.profile.names}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    const Text('Portal docente · Gestión 2026',
                                        style: TextStyle(
                                            color: Color(0xFFD9E5FF))),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 20),
                          Row(children: [
                            Expanded(
                              child: _MetricCard(
                                icon: Icons.menu_book_rounded,
                                value: '${rows.length}',
                                label: 'Materias',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MetricCard(
                                icon: Icons.groups_rounded,
                                value:
                                    '${rows.fold<int>(0, (sum, item) => sum + item.studentCount)}',
                                label: 'Estudiantes',
                              ),
                            ),
                          ]),
                          const SizedBox(height: 24),
                          Text('Mis materias',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const Text(
                              'Gestiona tareas, asistencia, notas y anuncios.'),
                          const SizedBox(height: 12),
                          for (final a in rows)
                            Card(
                                child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(a.subjectName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                          Text(
                                              '${a.courseName} · ${a.periodName}'),
                                          const SizedBox(height: 12),
                                          Row(children: [
                                            const Icon(Icons.groups_outlined,
                                                size: 20),
                                            const SizedBox(width: 6),
                                            Text(
                                                '${a.studentCount} estudiantes'),
                                            const Spacer(),
                                            FilledButton.tonal(
                                                onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            TeacherCourseScreen(
                                                                assignment:
                                                                    a))),
                                                child: const Text('Ver curso'))
                                          ])
                                        ])))
                        ]);
                  }))
        ]));
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(label),
            ]),
          ]),
        ),
      );
}
