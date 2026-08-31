import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/academic_entities.dart';
import '../services/student_service.dart';
import '../widgets/app_states.dart';
import '../widgets/status_banner.dart';
import 'student_course_detail_screen.dart';
import 'student_courses_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen(
      {super.key, required this.profile, this.onDemoLogout});
  final Profile profile;
  final VoidCallback? onDemoLogout;
  @override
  State<StudentDashboardScreen> createState() => _State();
}

class _State extends State<StudentDashboardScreen> {
  late Future<List<CourseAssignment>> future;
  StudentService get service =>
      StudentService(useSupabase: context.read<AppConfig>().useSupabase);
  @override
  void initState() {
    super.initState();
    future = Future.value([]);
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  void load() =>
      setState(() => future = service.myCourses(widget.profile.studentId!));
  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    return Scaffold(
        appBar: AppBar(title: const Text('Mi espacio académico'), actions: [
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
                    final courses = snapshot.data!;
                    return ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text('Hola, ${widget.profile.names}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Text(courses.isEmpty
                              ? 'Tu información académica'
                              : 'Periodo académico: ${courses.first.periodName}'),
                          const SizedBox(height: 20),
                          Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: ListTile(
                                  leading: const Icon(Icons.school, size: 38),
                                  title: Text(
                                      '${courses.length} cursos activos',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: const Text(
                                      'Consulta notas, asistencia y anuncios'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => StudentCoursesScreen(
                                              profile: widget.profile))))),
                          const SizedBox(height: 20),
                          Text('Mis cursos',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          if (courses.isEmpty)
                            const EmptyState(
                                icon: Icons.auto_stories_outlined,
                                title: 'No estás matriculado todavía',
                                message:
                                    'Cuando seas matriculado en un curso, aparecerá aquí.'),
                          for (final a in courses.take(3))
                            Card(
                                child: ListTile(
                                    leading: const CircleAvatar(
                                        child: Icon(Icons.menu_book)),
                                    title: Text(a.subjectName),
                                    subtitle:
                                        Text('${a.teacherName}\n${a.schedule}'),
                                    isThreeLine: a.schedule.isNotEmpty,
                                    trailing: const Icon(Icons.arrow_forward),
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                StudentCourseDetailScreen(
                                                    profile: widget.profile,
                                                    assignment: a)))))
                        ]);
                  }))
        ]));
  }
}
