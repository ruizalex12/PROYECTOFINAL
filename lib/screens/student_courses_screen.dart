import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/academic_entities.dart';
import '../services/student_service.dart';
import '../widgets/app_states.dart';
import 'student_course_detail_screen.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key, required this.profile});
  final Profile profile;
  @override
  State<StudentCoursesScreen> createState() => _State();
}

class _State extends State<StudentCoursesScreen> {
  late Future<List<CourseAssignment>> future;
  @override
  void initState() {
    super.initState();
    future = Future.value([]);
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  void load() => setState(() => future =
      StudentService(useSupabase: context.read<AppConfig>().useSupabase)
          .myCourses(widget.profile.studentId!));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Mis cursos')),
        body: FutureBuilder<List<CourseAssignment>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError)
                return ErrorState(
                    message: friendlyError(snapshot.error!), retry: load);
              final rows = snapshot.data!;
              if (rows.isEmpty)
                return const EmptyState(
                    icon: Icons.class_outlined,
                    title: 'No tienes cursos',
                    message:
                        'Solo verás los cursos en los que estés matriculado.');
              return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final a = rows[index];
                    return Card(
                        child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading:
                                const CircleAvatar(child: Icon(Icons.book)),
                            title: Text(a.subjectName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${a.teacherName}\n${a.periodName} · ${a.room}'),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => StudentCourseDetailScreen(
                                        profile: widget.profile,
                                        assignment: a)))));
                  });
            }));
  }
}
