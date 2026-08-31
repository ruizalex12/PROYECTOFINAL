import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/academic_entities.dart';
import '../services/enrollment_service.dart';
import '../widgets/app_states.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});
  @override
  State<AssignmentScreen> createState() => _AssignmentState();
}

class _AssignmentState extends State<AssignmentScreen> {
  Teacher? teacher;
  Subject? subject;
  Course? course;
  AcademicPeriod? period;
  final room = TextEditingController(), schedule = TextEditingController();
  bool busy = false;
  late Future<List<dynamic>> data;
  EnrollmentService get service =>
      EnrollmentService(useSupabase: context.read<AppConfig>().useSupabase);
  @override
  void initState() {
    super.initState();
    data = Future.value([]);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => setState(() => data = Future.wait([
              service.teachers(),
              service.subjects(),
              service.courses(),
              service.activePeriods()
            ])));
  }

  @override
  void dispose() {
    room.dispose();
    schedule.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (teacher == null ||
        subject == null ||
        course == null ||
        period == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todas las selecciones.')));
      return;
    }
    setState(() => busy = true);
    try {
      await service.assign(
          teacherId: teacher!.id,
          subjectId: subject!.id,
          courseId: course!.id,
          periodId: period!.id,
          room: room.text.trim(),
          schedule: schedule.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Docente asignado correctamente.')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Asignar docente')),
      body: FutureBuilder<List<dynamic>>(
          future: data,
          builder: (context, s) {
            if (s.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (s.hasError) {
              return ErrorState(
                  message: friendlyError(s.error!),
                  retry: () => setState(() => data = Future.wait([
                        service.teachers(),
                        service.subjects(),
                        service.courses(),
                        service.activePeriods()
                      ])));
            }
            final teachers = s.data![0] as List<Teacher>,
                subjects = s.data![1] as List<Subject>,
                courses = s.data![2] as List<Course>,
                periods = s.data![3] as List<AcademicPeriod>;
            return ListView(padding: const EdgeInsets.all(20), children: [
              Text('Nueva asignación',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              DropdownButtonFormField<Teacher>(
                  decoration: const InputDecoration(labelText: 'Docente'),
                  items: teachers
                      .map((x) =>
                          DropdownMenuItem(value: x, child: Text(x.fullName)))
                      .toList(),
                  onChanged: (v) => teacher = v),
              const SizedBox(height: 14),
              DropdownButtonFormField<Subject>(
                  decoration: const InputDecoration(labelText: 'Materia'),
                  items: subjects
                      .map((x) =>
                          DropdownMenuItem(value: x, child: Text(x.name)))
                      .toList(),
                  onChanged: (v) => subject = v),
              const SizedBox(height: 14),
              DropdownButtonFormField<Course>(
                  decoration: const InputDecoration(labelText: 'Curso'),
                  items: courses
                      .map((x) => DropdownMenuItem(
                          value: x, child: Text('${x.name} · ${x.parallel}')))
                      .toList(),
                  onChanged: (v) => course = v),
              const SizedBox(height: 14),
              DropdownButtonFormField<AcademicPeriod>(
                  decoration:
                      const InputDecoration(labelText: 'Periodo activo'),
                  items: periods
                      .map((x) =>
                          DropdownMenuItem(value: x, child: Text(x.name)))
                      .toList(),
                  onChanged: (v) => period = v),
              const SizedBox(height: 14),
              TextField(
                  controller: room,
                  decoration:
                      const InputDecoration(labelText: 'Aula (opcional)')),
              const SizedBox(height: 14),
              TextField(
                  controller: schedule,
                  decoration:
                      const InputDecoration(labelText: 'Horario (opcional)')),
              const SizedBox(height: 22),
              FilledButton.icon(
                  onPressed: busy ? null : save,
                  icon: const Icon(Icons.assignment_ind),
                  label: Text(busy ? 'Guardando...' : 'Guardar asignación'))
            ]);
          }));
}
