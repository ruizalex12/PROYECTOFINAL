import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/academic_entities.dart';
import '../services/enrollment_service.dart';
import '../widgets/app_states.dart';

class UserRolesScreen extends StatefulWidget {
  const UserRolesScreen({super.key});
  @override
  State<UserRolesScreen> createState() => _State();
}

class _State extends State<UserRolesScreen> {
  late Future<List<dynamic>> future;
  EnrollmentService get service =>
      EnrollmentService(useSupabase: context.read<AppConfig>().useSupabase);
  @override
  void initState() {
    super.initState();
    future = Future.value([]);
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  void load() => setState(() => future = Future.wait(
      [service.profiles(), service.students(), service.teachers()]));
  Future<void> edit(
      Profile p, List<Student> students, List<Teacher> teachers) async {
    var role = p.role;
    String? studentId = p.studentId, teacherId = p.teacherId;
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => StatefulBuilder(
            builder: (c, set) => AlertDialog(
                    title: Text(p.email.isEmpty ? p.fullName : p.email),
                    content: SizedBox(
                        width: 440,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          DropdownButtonFormField<UserRole>(
                              initialValue: role,
                              decoration:
                                  const InputDecoration(labelText: 'Rol'),
                              items: UserRole.values
                                  .map((x) => DropdownMenuItem(
                                      value: x, child: Text(x.name)))
                                  .toList(),
                              onChanged: (v) => set(() => role = v ?? role)),
                          if (role == UserRole.estudiante) ...[
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                                initialValue: studentId,
                                decoration: const InputDecoration(
                                    labelText: 'Vincular estudiante'),
                                items: students
                                    .map((x) => DropdownMenuItem(
                                        value: x.id, child: Text(x.fullName)))
                                    .toList(),
                                onChanged: (v) => studentId = v)
                          ],
                          if (role == UserRole.docente) ...[
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                                initialValue: teacherId,
                                decoration: const InputDecoration(
                                    labelText: 'Vincular docente'),
                                items: teachers
                                    .map((x) => DropdownMenuItem(
                                        value: x.id, child: Text(x.fullName)))
                                    .toList(),
                                onChanged: (v) => teacherId = v)
                          ]
                        ])),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancelar')),
                      FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Guardar'))
                    ])));
    if (ok == true) {
      try {
        await service.linkProfile(
            profileId: p.id,
            role: role,
            studentId: studentId,
            teacherId: teacherId);
        load();
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Rol actualizado.')));
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Usuarios y roles')),
      body: FutureBuilder<List<dynamic>>(
          future: future,
          builder: (c, s) {
            if (s.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (s.hasError)
              return ErrorState(message: friendlyError(s.error!), retry: load);
            final profiles = s.data![0] as List<Profile>,
                students = s.data![1] as List<Student>,
                teachers = s.data![2] as List<Teacher>;
            return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: profiles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = profiles[i];
                  return Card(
                      child: ListTile(
                          leading: CircleAvatar(
                              child: Icon(p.role == UserRole.admin
                                  ? Icons.admin_panel_settings
                                  : p.role == UserRole.docente
                                      ? Icons.co_present
                                      : Icons.school)),
                          title:
                              Text(p.fullName.isEmpty ? p.email : p.fullName),
                          subtitle: Text('${p.email}\nRol: ${p.role.name}'),
                          isThreeLine: true,
                          trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => edit(p, students, teachers))));
                });
          }));
}
