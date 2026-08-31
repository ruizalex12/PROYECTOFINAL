import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/academic_entities.dart';
import '../services/student_service.dart';
import '../widgets/app_states.dart';

class StudentCourseDetailScreen extends StatefulWidget {
  const StudentCourseDetailScreen(
      {super.key, required this.profile, required this.assignment});
  final Profile profile;
  final CourseAssignment assignment;
  @override
  State<StudentCourseDetailScreen> createState() => _State();
}

class _State extends State<StudentCourseDetailScreen> {
  late Future<StudentCourseData> future;
  late Future<List<Map<String, dynamic>>> taskFuture;
  late Future<List<Map<String, dynamic>>> attendanceFuture;
  @override
  void initState() {
    super.initState();
    future = Future.value(StudentCourseData(
        assignment: widget.assignment,
        grades: const [],
        attendance: const [],
        announcements: const []));
    taskFuture = Future.value([]);
    attendanceFuture = Future.value([]);
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  void load() {
    final service =
        StudentService(useSupabase: context.read<AppConfig>().useSupabase);
    setState(() {
      future =
          service.courseData(widget.profile.studentId ?? '', widget.assignment);
      taskFuture =
          service.tasks(widget.assignment.id, widget.profile.studentId ?? '');
      attendanceFuture = service.openAttendanceSessionsForCourse(
          widget.profile.studentId ?? '', widget.assignment.id);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(widget.assignment.subjectName)),
      body: FutureBuilder<StudentCourseData>(
          future: future,
          builder: (c, s) {
            if (s.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (s.hasError) {
              return ErrorState(message: friendlyError(s.error!), retry: load);
            }
            final d = s.data!;
            final present =
                    d.attendance.where((x) => x['estado'] == 'Presente').length,
                justified = d.attendance
                    .where((x) => x['estado'] == 'Justificado')
                    .length,
                absent =
                    d.attendance.where((x) => x['estado'] == 'Ausente').length;
            return ListView(padding: const EdgeInsets.all(20), children: [
              _Section(
                  title: 'Información',
                  icon: Icons.info_outline,
                  child: Column(children: [
                    _row('Materia', d.assignment.subjectName),
                    _row('Docente', d.assignment.teacherName),
                    _row('Periodo', d.assignment.periodName),
                    _row(
                        'Horario',
                        d.assignment.schedule.isEmpty
                            ? '-'
                            : d.assignment.schedule),
                    _row('Aula',
                        d.assignment.room.isEmpty ? '-' : d.assignment.room)
                  ])),
              const SizedBox(height: 16),
              _Section(
                  title: 'Tareas',
                  icon: Icons.assignment_outlined,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: taskFuture,
                      builder: (context, tasks) {
                        if (!tasks.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (tasks.data!.isEmpty) {
                          return const Text(
                              'No hay tareas publicadas en esta materia.');
                        }
                        return Column(children: [
                          for (final task in tasks.data!)
                            ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(task['titulo'].toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${task['descripcion']}\nLímite: ${task['fecha_limite']}'),
                                isThreeLine: true,
                                trailing: Chip(
                                    label: Text(
                                        (task['entregas_tarea'] as List).isEmpty
                                            ? 'Pendiente'
                                            : 'Entregada')),
                                onTap: () => _submitTask(task))
                        ]);
                      })),
              const SizedBox(height: 16),
              _Section(
                  title: 'Calificaciones',
                  icon: Icons.grade_outlined,
                  child: Column(children: [
                    if (d.grades.isEmpty)
                      const Text('Este curso aún no tiene calificaciones.'),
                    ...d.grades.map((g) => _row(g['titulo'].toString(),
                        (g['nota'] as num).toStringAsFixed(1))),
                    const Divider(),
                    _row('Promedio', d.average.toStringAsFixed(1), strong: true)
                  ])),
              const SizedBox(height: 16),
              _Section(
                  title: 'Asistencia',
                  icon: Icons.fact_check_outlined,
                  child: Column(children: [
                    _row('Presentes', '$present'),
                    _row('Faltas', '$absent'),
                    _row('Justificadas', '$justified'),
                    const Divider(),
                    _row('Porcentaje',
                        '${d.attendancePercent.toStringAsFixed(1)}%',
                        strong: true),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Map<String, dynamic>>>(
                        future: attendanceFuture,
                        builder: (context, sessions) {
                          if (!sessions.hasData) {
                            return const LinearProgressIndicator();
                          }
                          if (sessions.data!.isEmpty) {
                            return const ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.lock_clock_outlined),
                                title: Text('Asistencia no disponible'),
                                subtitle: Text(
                                    'El docente todavía no abrió el registro para esta materia.'));
                          }
                          final session = sessions.data!.first;
                          return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                  child: Icon(Icons.how_to_reg)),
                              title: Text(
                                  (session['titulo'] ?? 'Asistencia de hoy')
                                      .toString()),
                              subtitle: Text(
                                  'Disponible hasta ${session['cierra_en']}'),
                              trailing: FilledButton.tonalIcon(
                                  onPressed: () => _checkAttendance(session),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Marcar')));
                        })
                  ])),
              const SizedBox(height: 16),
              _Section(
                  title: 'Anuncios',
                  icon: Icons.campaign_outlined,
                  child: Column(children: [
                    if (d.announcements.isEmpty)
                      const Text('No hay anuncios para este curso.'),
                    ...d.announcements.map((a) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(a.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(a.content)))
                  ]))
            ]);
          }));
  Future<void> _submitTask(Map<String, dynamic> task) async {
    final comment = TextEditingController();
    final studentService =
        StudentService(useSupabase: context.read<AppConfig>().useSupabase);
    PlatformFile? selectedFile;
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                    title: Text(task['titulo'].toString()),
                    content: SizedBox(
                        width: 430,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          TextField(
                              controller: comment,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                  labelText: 'Comentario de entrega (opcional)',
                                  hintText:
                                      'Añade una nota para el docente...')),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                              onPressed: () async {
                                final result = await FilePicker.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: const [
                                      'txt',
                                      'pdf',
                                      'doc',
                                      'docx',
                                      'jpg',
                                      'jpeg',
                                      'png'
                                    ]);
                                if (result.isNotEmpty) {
                                  setDialogState(
                                      () => selectedFile = result.single);
                                }
                              },
                              icon: const Icon(Icons.attach_file),
                              label: const Text('Buscar archivo')),
                          if (selectedFile != null)
                            ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.description_outlined),
                                title: Text(selectedFile!.name),
                                subtitle:
                                    const Text('Archivo listo para entregar'),
                                trailing: IconButton(
                                    onPressed: () => setDialogState(
                                        () => selectedFile = null),
                                    icon: const Icon(Icons.close)))
                        ])),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancelar')),
                      FilledButton(
                          onPressed: selectedFile == null
                              ? null
                              : () => Navigator.pop(c, true),
                          child: const Text('Entregar tarea'))
                    ])));
    if (ok == true) {
      try {
        final bytes = await selectedFile!.readAsBytes();
        await studentService.submitTask(
            taskId: task['id'].toString(),
            studentId: widget.profile.studentId!,
            comment: comment.text,
            fileName: selectedFile!.name,
            fileBytes: bytes);
        load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tarea entregada correctamente.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(friendlyError(e))));
        }
      }
    }
    comment.dispose();
  }

  Future<void> _checkAttendance(Map<String, dynamic> session) async {
    try {
      await StudentService(useSupabase: context.read<AppConfig>().useSupabase)
          .checkIn(widget.profile.studentId!, widget.assignment.id,
              sessionId: session['id'].toString());
      load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Asistencia marcada correctamente.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }
  }

  Widget _row(String a, String b, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(child: Text(a)),
        Text(b,
            style: TextStyle(
                fontWeight: strong ? FontWeight.bold : FontWeight.normal))
      ]));
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold))
            ]),
            const Divider(height: 24),
            child
          ])));
}
