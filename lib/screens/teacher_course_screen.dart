import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/academic_entities.dart';
import '../services/teacher_service.dart';
import '../widgets/app_states.dart';

class TeacherCourseScreen extends StatefulWidget {
  const TeacherCourseScreen({super.key, required this.assignment});
  final CourseAssignment assignment;
  @override
  State<TeacherCourseScreen> createState() => _State();
}

class _State extends State<TeacherCourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabs;
  late Future<List<Student>> students;
  late Future<List<Evaluation>> evaluations;
  late Future<List<Map<String, dynamic>>> taskFuture;
  TeacherService get service =>
      TeacherService(useSupabase: context.read<AppConfig>().useSupabase);
  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 6, vsync: this);
    students = Future.value([]);
    evaluations = Future.value([]);
    taskFuture = Future.value([]);
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  void load() => setState(() {
        students = service.courseStudents(widget.assignment);
        evaluations = service.evaluations(widget.assignment.id);
        taskFuture = service.tasks(widget.assignment.id);
      });
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: Text(widget.assignment.subjectName),
          bottom: TabBar(controller: tabs, isScrollable: true, tabs: const [
            Tab(text: 'Estudiantes'),
            Tab(text: 'Asistencia'),
            Tab(text: 'Tareas'),
            Tab(text: 'Evaluaciones'),
            Tab(text: 'Notas'),
            Tab(text: 'Anuncios')
          ])),
      body: TabBarView(controller: tabs, children: [
        studentList(),
        attendanceList(),
        taskList(),
        evaluationList(),
        gradeList(),
        announcementView()
      ]));
  Widget studentList() => FutureBuilder<List<Student>>(
      future: students,
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        if (s.data!.isEmpty)
          return const EmptyState(
              icon: Icons.person_off,
              title: 'Curso sin estudiantes',
              message: 'Los estudiantes matriculados aparecerán aquí.');
        return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: s.data!.length,
            itemBuilder: (_, i) => ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(s.data![i].fullName),
                subtitle: Text(s.data![i].code)));
      });
  Widget attendanceList() => FutureBuilder<List<Student>>(
      future: students,
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final date = DateTime.now().toIso8601String().substring(0, 10);
        return ListView(padding: const EdgeInsets.all(16), children: [
          Text('Asistencia · $date',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: openAttendance,
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('Abrir asistencia para estudiantes')),
          const SizedBox(height: 12),
          const Text('Registro y corrección manual:'),
          for (final student in s.data!)
            _AttendanceTile(
                student: student,
                onSave: (status) => service.saveAttendance(
                    widget.assignment.id, student.id, date, status))
        ]);
      });
  Widget taskList() => FutureBuilder<List<Map<String, dynamic>>>(
      future: taskFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        return ListView(padding: const EdgeInsets.all(16), children: [
          FilledButton.icon(
              onPressed: () => taskForm(),
              icon: const Icon(Icons.add_task),
              label: const Text('Nueva tarea')),
          const SizedBox(height: 12),
          if (snapshot.data!.isEmpty)
            const EmptyState(
                icon: Icons.assignment_outlined,
                title: 'Sin tareas',
                message: 'Crea una tarea para tus estudiantes.'),
          for (final task in snapshot.data!)
            Card(
                child: ListTile(
                    title: Text(task['titulo'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${task['descripcion']}\nLímite: ${task['fecha_limite']}'),
                    isThreeLine: true,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => _SubmissionsScreen(
                                task: task, service: service))),
                    trailing: PopupMenuButton<String>(
                        onSelected: (v) =>
                            v == 'edit' ? taskForm(task) : deleteTask(task),
                        itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: 'edit', child: Text('Editar')),
                              PopupMenuItem(
                                  value: 'delete', child: Text('Eliminar'))
                            ])))
        ]);
      });
  Future<void> taskForm([Map<String, dynamic>? task]) async {
    final title =
            TextEditingController(text: task?['titulo']?.toString() ?? ''),
        description =
            TextEditingController(text: task?['descripcion']?.toString() ?? ''),
        deadline = TextEditingController(
            text: task?['fecha_limite']?.toString() ??
                DateTime.now().add(const Duration(days: 7)).toIso8601String());
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(task == null ? 'Nueva tarea' : 'Editar tarea'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'Título')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: description,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: 'Descripción')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: deadline,
                      decoration:
                          const InputDecoration(labelText: 'Fecha límite'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Guardar'))
                ]));
    if (ok == true) {
      try {
        await service.saveTask(
            id: task?['id']?.toString(),
            assignmentId: widget.assignment.id,
            title: title.text,
            description: description.text,
            deadline: deadline.text);
        load();
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }
    title.dispose();
    description.dispose();
    deadline.dispose();
  }

  Future<void> deleteTask(Map<String, dynamic> task) async {
    await service.deleteTask(task['id'].toString());
    load();
  }

  Future<void> openAttendance() async {
    final title = TextEditingController(
            text: 'Clase ${widget.assignment.subjectName}'),
        minutes = TextEditingController(text: '30');
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Abrir asistencia'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'Sesión')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: minutes,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Minutos disponible'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Abrir'))
                ]));
    if (ok == true) {
      try {
        await service.openAttendance(
            widget.assignment.id, title.text, int.tryParse(minutes.text) ?? 30);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Asistencia abierta.')));
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }
    title.dispose();
    minutes.dispose();
  }

  Widget evaluationList() => FutureBuilder<List<Evaluation>>(
      future: evaluations,
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(padding: const EdgeInsets.all(16), children: [
          FilledButton.icon(
              onPressed: newEvaluation,
              icon: const Icon(Icons.add),
              label: const Text('Nueva evaluación')),
          if (s.data!.isEmpty)
            const EmptyState(
                icon: Icons.quiz,
                title: 'Sin evaluaciones',
                message: 'Crea la primera evaluación.'),
          for (final e in s.data!)
            Card(
                child: ListTile(
                    title: Text(e.title),
                    subtitle: Text('${e.date} · ${e.weight}%'),
                    trailing: Chip(label: Text(e.type))))
        ]);
      });
  Widget gradeList() => FutureBuilder<List<dynamic>>(
      future: Future.wait([students, evaluations]),
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final studentRows = s.data![0] as List<Student>;
        final evaluationRows = s.data![1] as List<Evaluation>;
        if (evaluationRows.isEmpty)
          return const EmptyState(
              icon: Icons.assignment_late,
              title: 'Primero crea una evaluación',
              message: 'Las notas pertenecen a una evaluación existente.');
        final widgets = <Widget>[];
        for (final evaluation in evaluationRows) {
          widgets.add(Text(evaluation.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)));
          for (final student in studentRows) {
            widgets.add(ListTile(
                title: Text(student.fullName),
                trailing: SizedBox(
                    width: 90,
                    child: TextField(
                        key: ValueKey('${evaluation.id}-${student.id}'),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Nota'),
                        onSubmitted: (value) =>
                            saveGrade(evaluation.id, student.id, value)))));
          }
          widgets.add(const Divider());
        }
        return ListView(padding: const EdgeInsets.all(16), children: widgets);
      });
  Future<void> saveGrade(
      String evaluationId, String studentId, String value) async {
    final score = double.tryParse(value);
    if (score == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa una nota válida.')));
      return;
    }
    try {
      await service.saveGrade(evaluationId, studentId, score);
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Nota guardada.')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  Widget announcementView() => Center(
      child: FilledButton.icon(
          onPressed: newAnnouncement,
          icon: const Icon(Icons.campaign),
          label: const Text('Publicar anuncio')));
  Future<void> newEvaluation() async {
    final title = TextEditingController(),
        type = TextEditingController(),
        weight = TextEditingController();
    final date = DateTime.now().toIso8601String().substring(0, 10);
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Nueva evaluación'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'Nombre')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: type,
                      decoration: const InputDecoration(labelText: 'Tipo')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: weight,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Porcentaje'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Crear'))
                ]));
    if (ok == true) {
      try {
        await service.createEvaluation(widget.assignment.id, title.text,
            type.text, date, double.tryParse(weight.text) ?? 0);
        load();
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }
  }

  Future<void> newAnnouncement() async {
    final title = TextEditingController(), content = TextEditingController();
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Nuevo anuncio'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'Título')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: content,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Contenido'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Publicar'))
                ]));
    if (ok == true) {
      await service.publish(widget.assignment.id, title.text, content.text);
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Anuncio publicado.')));
    }
  }
}

class _SubmissionsScreen extends StatefulWidget {
  const _SubmissionsScreen({required this.task, required this.service});
  final Map<String, dynamic> task;
  final TeacherService service;
  @override
  State<_SubmissionsScreen> createState() => _SubmissionsState();
}

class _SubmissionsState extends State<_SubmissionsScreen> {
  late Future<List<Map<String, dynamic>>> future;
  @override
  void initState() {
    super.initState();
    load();
  }

  void load() => setState(
      () => future = widget.service.submissions(widget.task['id'].toString()));
  Future<void> grade(Map<String, dynamic> row) async {
    final score = TextEditingController(text: row['nota']?.toString() ?? ''),
        feedback = TextEditingController(
            text: row['retroalimentacion']?.toString() ?? '');
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Calificar entrega'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: score,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nota')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: feedback,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: 'Retroalimentación'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Guardar'))
                ]));
    if (ok == true) {
      try {
        await widget.service.gradeSubmission(
            row['id'].toString(),
            double.tryParse(score.text) ?? -1,
            feedback.text,
            (widget.task['puntaje_maximo'] as num).toDouble());
        load();
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }
    score.dispose();
    feedback.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(widget.task['titulo'].toString())),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, s) {
            if (!s.hasData)
              return const Center(child: CircularProgressIndicator());
            if (s.data!.isEmpty)
              return const EmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'Sin entregas todavía',
                  message: 'Las entregas de estudiantes aparecerán aquí.');
            return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: s.data!.length,
                itemBuilder: (_, i) {
                  final row = s.data![i], student = row['estudiantes'] as Map?;
                  return Card(
                      child: ListTile(
                          title: Text(student == null
                              ? 'Estudiante'
                              : '${student['nombres']} ${student['apellidos']}'),
                          subtitle: Text(
                              '${row['comentario']}\nNota: ${row['nota'] ?? 'Pendiente'}'),
                          isThreeLine: true,
                          trailing: FilledButton.tonal(
                              onPressed: () => grade(row),
                              child: const Text('Calificar'))));
                });
          }));
}

class _AttendanceTile extends StatefulWidget {
  const _AttendanceTile({required this.student, required this.onSave});
  final Student student;
  final Future<void> Function(String) onSave;
  @override
  State<_AttendanceTile> createState() => _AttendanceTileState();
}

class _AttendanceTileState extends State<_AttendanceTile> {
  String value = 'Presente';
  @override
  Widget build(BuildContext context) => ListTile(
      title: Text(widget.student.fullName),
      trailing: DropdownButton<String>(
          value: value,
          items: const ['Presente', 'Ausente', 'Justificado']
              .map((x) => DropdownMenuItem(value: x, child: Text(x)))
              .toList(),
          onChanged: (v) async {
            if (v != null) {
              setState(() => value = v);
              try {
                await widget.onSave(v);
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${widget.student.fullName}: $v')));
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(friendlyError(e))));
              }
            }
          }));
}
