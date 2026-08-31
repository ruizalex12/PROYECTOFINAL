import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/academic_entities.dart';
import '../services/enrollment_service.dart';
import '../widgets/app_states.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});
  @override
  State<EnrollmentScreen> createState() => _EnrollmentState();
}

class _EnrollmentState extends State<EnrollmentScreen> {
  Student? student;
  Course? course;
  AcademicPeriod? period;
  bool busy = false;
  late Future<List<dynamic>> data;
  EnrollmentService get service =>
      EnrollmentService(useSupabase: context.read<AppConfig>().useSupabase);
  @override
  void initState() {
    super.initState();
    data = Future.value([]);
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => data =
        Future.wait(
            [service.students(), service.courses(), service.activePeriods()])));
  }

  Future<void> save() async {
    if (student == null || course == null || period == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selecciona estudiante, periodo y curso.')));
      return;
    }
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Confirmar matrícula'),
                content: Text(
                    '${student!.fullName}\n${course!.name} · ${period!.name}'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Matricular'))
                ]));
    if (ok != true) return;
    setState(() => busy = true);
    try {
      await service.enroll(
          studentId: student!.id, courseId: course!.id, periodId: period!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Matrícula registrada correctamente.')));
        setState(() {
          student = null;
          course = null;
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Nueva matrícula')),
      body: FutureBuilder<List<dynamic>>(
          future: data,
          builder: (context, s) {
            if (s.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (s.hasError)
              return ErrorState(
                  message: friendlyError(s.error!),
                  retry: () => setState(() => data = Future.wait([
                        service.students(),
                        service.courses(),
                        service.activePeriods()
                      ])));
            final students = s.data![0] as List<Student>,
                courses = s.data![1] as List<Course>,
                periods = s.data![2] as List<AcademicPeriod>;
            return ListView(padding: const EdgeInsets.all(20), children: [
              Text('Matricular estudiante',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Text(
                  'Selecciona los datos académicos. Solo se muestran periodos activos.'),
              const SizedBox(height: 24),
              DropdownButtonFormField<Student>(
                  initialValue: student,
                  decoration: const InputDecoration(
                      labelText: 'Estudiante', prefixIcon: Icon(Icons.person)),
                  items: students
                      .map((x) => DropdownMenuItem(
                          value: x, child: Text('${x.code} · ${x.fullName}')))
                      .toList(),
                  onChanged: (v) => setState(() => student = v)),
              const SizedBox(height: 16),
              DropdownButtonFormField<AcademicPeriod>(
                  initialValue: period,
                  decoration: const InputDecoration(
                      labelText: 'Periodo activo',
                      prefixIcon: Icon(Icons.calendar_month)),
                  items: periods
                      .map((x) =>
                          DropdownMenuItem(value: x, child: Text(x.name)))
                      .toList(),
                  onChanged: (v) => setState(() => period = v)),
              const SizedBox(height: 16),
              DropdownButtonFormField<Course>(
                  initialValue: course,
                  decoration: const InputDecoration(
                      labelText: 'Curso', prefixIcon: Icon(Icons.class_)),
                  items: courses
                      .map((x) => DropdownMenuItem(
                          value: x, child: Text('${x.name} · ${x.parallel}')))
                      .toList(),
                  onChanged: (v) => setState(() => course = v)),
              const SizedBox(height: 24),
              FilledButton.icon(
                  onPressed: busy ? null : save,
                  icon: const Icon(Icons.how_to_reg),
                  label: Text(busy ? 'Guardando...' : 'Confirmar matrícula'))
            ]);
          }));
}
