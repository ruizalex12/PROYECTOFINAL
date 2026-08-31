import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/academic_entities.dart';
import '../services/student_service.dart';
import '../widgets/app_states.dart';
import '../widgets/status_banner.dart';
import 'student_course_detail_screen.dart';

class StudentPortalScreen extends StatefulWidget {
  const StudentPortalScreen(
      {super.key, required this.profile, this.onDemoLogout});
  final Profile profile;
  final VoidCallback? onDemoLogout;
  @override
  State<StudentPortalScreen> createState() => _PortalState();
}

class _PortalState extends State<StudentPortalScreen> {
  int index = 0;
  StudentService get service =>
      StudentService(useSupabase: context.read<AppConfig>().useSupabase);
  void logout() => context.read<AppConfig>().useSupabase
      ? Supabase.instance.client.auth.signOut()
      : widget.onDemoLogout?.call();
  @override
  Widget build(BuildContext context) {
    final pages = [
      _Home(widget.profile, service, (v) => setState(() => index = v)),
      _Courses(widget.profile, service),
      _Schedule(widget.profile, service),
      _Documents(widget.profile, service),
      _Profile(widget.profile, service, logout)
    ];
    return Scaffold(
      appBar: AppBar(
          title: const Row(children: [
            CircleAvatar(child: Icon(Icons.school)),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EduGestión', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Portal estudiantil', style: TextStyle(fontSize: 11))
            ])
          ]),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Badge(child: Icon(Icons.notifications_outlined)))
          ]),
      body: Column(children: [
        StatusBanner(demoMode: !context.watch<AppConfig>().useSupabase),
        Expanded(child: IndexedStack(index: index, children: pages))
      ]),
      bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (v) => setState(() => index = v),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined), label: 'Inicio'),
            NavigationDestination(
                icon: Icon(Icons.menu_book_outlined), label: 'Materias'),
            NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined), label: 'Horario'),
            NavigationDestination(
                icon: Icon(Icons.folder_outlined), label: 'Archivos'),
            NavigationDestination(
                icon: Icon(Icons.person_outline), label: 'Perfil')
          ]),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home(this.profile, this.service, this.navigate);
  final Profile profile;
  final StudentService service;
  final ValueChanged<int> navigate;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<CourseAssignment>>(
      future: service.myCourses(profile.studentId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final courses = snapshot.data!;
        return ListView(padding: const EdgeInsets.all(20), children: [
          Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF3157D5), Color(0xFF6337C8)]),
                  borderRadius: BorderRadius.circular(24)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¡Hola, ${profile.names}! 👋',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                    const Text(
                        'Continúa avanzando en tu formación profesional.',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 14),
                    Chip(
                        label: Text(courses.isEmpty
                            ? 'Sin periodo activo'
                            : courses.first.periodName))
                  ])),
          const SizedBox(height: 22),
          Text('Accesos rápidos',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _Quick(Icons.book, 'Mis materias', () => navigate(1)),
                _Quick(Icons.fact_check, 'Asistencia', () => navigate(2)),
                _Quick(Icons.folder, 'Documentos', () => navigate(3)),
                _Quick(Icons.person, 'Mi perfil', () => navigate(4))
              ]),
          const SizedBox(height: 22),
          Text('Mis clases',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (courses.isEmpty)
            const EmptyState(
                icon: Icons.auto_stories,
                title: 'Sin materias activas',
                message: 'Tus materias aparecerán después de la matrícula.'),
          for (final course in courses.take(3))
            _CourseCard(profile: profile, course: course),
        ]);
      });
}

class _Quick extends StatelessWidget {
  const _Quick(this.icon, this.label, this.tap);
  final IconData icon;
  final String label;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => Card(
      child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: tap,
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                CircleAvatar(child: Icon(icon)),
                const SizedBox(width: 9),
                Expanded(
                    child: Text(label,
                        style: const TextStyle(fontWeight: FontWeight.w600)))
              ]))));
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.profile, required this.course});
  final Profile profile;
  final CourseAssignment course;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
          child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(child: Icon(Icons.menu_book)),
              title: Text(course.subjectName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${course.teacherName}\n${course.schedule} · ${course.room}'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => StudentCourseDetailScreen(
                          profile: profile, assignment: course))))));
}

class _Courses extends StatelessWidget {
  const _Courses(this.profile, this.service);
  final Profile profile;
  final StudentService service;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<CourseAssignment>>(
      future: service.myCourses(profile.studentId!),
      builder: (context, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(padding: const EdgeInsets.all(20), children: [
          Text('Mis materias',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Text('Notas, asistencia, información y anuncios'),
          const SizedBox(height: 18),
          if (s.data!.isEmpty)
            const EmptyState(
                icon: Icons.book_outlined,
                title: 'No tienes materias',
                message: 'Solo verás materias donde estés matriculado.'),
          for (final c in s.data!) _CourseCard(profile: profile, course: c)
        ]);
      });
}

class _Schedule extends StatefulWidget {
  const _Schedule(this.profile, this.service);
  final Profile profile;
  final StudentService service;
  @override
  State<_Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<_Schedule> {
  late Future<List<dynamic>> future;
  @override
  void initState() {
    super.initState();
    future = Future.wait([
      widget.service.schedule(widget.profile.studentId!),
      widget.service.openAttendanceSessions(widget.profile.studentId!)
    ]);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final hours = s.data![0] as List<Map<String, dynamic>>,
            sessions = s.data![1] as List<Map<String, dynamic>>;
        return ListView(padding: const EdgeInsets.all(20), children: [
          Text('Horario semanal',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Text('Consulta tus clases y registra tu llegada'),
          const SizedBox(height: 16),
          for (final h in hours)
            Card(
                child: ListTile(
                    leading: CircleAvatar(
                        child: Text(_day((h['dia_semana'] as num).toInt()))),
                    title: Text(
                        (h['asignaciones']?['materias']?['nombre'] ?? 'Materia')
                            .toString()),
                    subtitle: Text(
                        '${h['hora_inicio']} - ${h['hora_fin']} · Aula ${h['aula'] ?? '-'}'))),
          const SizedBox(height: 18),
          Text('Marcar asistencia de hoy',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (sessions.isEmpty)
            const Card(
                child: ListTile(
                    leading: Icon(Icons.lock_clock),
                    title: Text('No hay asistencia abierta'),
                    subtitle: Text(
                        'Aparecerá cuando el docente abra la asistencia de su materia.'))),
          for (final session in sessions)
            Card(
                child: ListTile(
                    title: Text((session['asignaciones']?['materias']
                                ?['nombre'] ??
                            session['titulo'] ??
                            'Clase')
                        .toString()),
                    subtitle: Text('Disponible hasta ${session['cierra_en']}'),
                    trailing: FilledButton.tonal(
                        onPressed: () => check(session),
                        child: const Text('Marcar'))))
        ]);
      });
  String _day(int n) => const ['', 'L', 'M', 'X', 'J', 'V', 'S', 'D'][n];
  Future<void> check(Map<String, dynamic> session) async {
    try {
      await widget.service.checkIn(
          widget.profile.studentId!, session['asignacion_id'].toString(),
          sessionId: session['id'].toString());
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
}

class _Documents extends StatefulWidget {
  const _Documents(this.profile, this.service);
  final Profile profile;
  final StudentService service;
  @override
  State<_Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<_Documents> {
  late Future<List<Map<String, dynamic>>> future;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final documents = await widget.service.documents(widget.profile.studentId!);
    if (!mounted) return;
    setState(() {
      future = Future.value(documents);
    });
  }

  Future<void> upload() async {
    final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'jpg', 'jpeg', 'png']);
    final file = result.single;
    final bytes = await file.readAsBytes();
    setState(() => busy = true);
    try {
      await widget.service.uploadDocument(
          studentId: widget.profile.studentId!, name: file.name, bytes: bytes);
      load();
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
  Widget build(BuildContext context) => FutureBuilder<
          List<Map<String, dynamic>>>(
      future: future,
      builder: (context, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(padding: const EdgeInsets.all(20), children: [
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Documentos',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Text('PDF, Word o imágenes · máximo 10 MB')
                ])),
            FilledButton.icon(
                onPressed: busy ? null : upload,
                icon: const Icon(Icons.upload_file),
                label: Text(busy ? 'Subiendo' : 'Subir'))
          ]),
          const SizedBox(height: 18),
          if (s.data!.isEmpty)
            const EmptyState(
                icon: Icons.folder_open,
                title: 'Carpeta vacía',
                message: 'Sube tus tareas y documentos académicos.'),
          for (final doc in s.data!)
            Card(
                child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.description)),
                    title: Text(doc['nombre'].toString()),
                    trailing: IconButton(
                        onPressed: () async {
                          await widget.service.deleteDocument(doc);
                          load();
                        },
                        icon: const Icon(Icons.delete_outline))))
        ]);
      });
}

class _Profile extends StatefulWidget {
  const _Profile(this.profile, this.service, this.logout);
  final Profile profile;
  final StudentService service;
  final VoidCallback logout;
  @override
  State<_Profile> createState() => _ProfileState();
}

class _ProfileState extends State<_Profile> {
  late final TextEditingController names, lastNames, phone, career;
  bool edit = false, busy = false;
  @override
  void initState() {
    super.initState();
    names = TextEditingController(text: widget.profile.names);
    lastNames = TextEditingController(text: widget.profile.lastNames);
    phone = TextEditingController();
    career = TextEditingController(text: 'Ingeniería Informática');
  }

  @override
  void dispose() {
    names.dispose();
    lastNames.dispose();
    phone.dispose();
    career.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() => busy = true);
    try {
      await widget.service.updateProfile(
          names: names.text,
          lastNames: lastNames.text,
          phone: phone.text,
          career: career.text);
      if (mounted) setState(() => edit = false);
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
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(20), children: [
        CircleAvatar(
            radius: 50,
            child: Text(
                widget.profile.names.isEmpty ? 'E' : widget.profile.names[0],
                style: Theme.of(context).textTheme.displaySmall)),
        const SizedBox(height: 12),
        Text(widget.profile.fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(widget.profile.email, textAlign: TextAlign.center),
        const SizedBox(height: 22),
        TextField(
            controller: names,
            enabled: edit,
            decoration: const InputDecoration(labelText: 'Nombres')),
        const SizedBox(height: 10),
        TextField(
            controller: lastNames,
            enabled: edit,
            decoration: const InputDecoration(labelText: 'Apellidos')),
        const SizedBox(height: 10),
        TextField(
            controller: phone,
            enabled: edit,
            decoration: const InputDecoration(labelText: 'Teléfono')),
        const SizedBox(height: 10),
        TextField(
            controller: career,
            enabled: edit,
            decoration: const InputDecoration(labelText: 'Carrera')),
        const SizedBox(height: 16),
        if (edit)
          FilledButton.icon(
              onPressed: busy ? null : save,
              icon: const Icon(Icons.save),
              label: const Text('Guardar cambios'))
        else
          FilledButton.tonalIcon(
              onPressed: () => setState(() => edit = true),
              icon: const Icon(Icons.edit),
              label: const Text('Editar perfil')),
        const SizedBox(height: 10),
        OutlinedButton.icon(
            onPressed: widget.logout,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'))
      ]);
}
