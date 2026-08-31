import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/academic_entities.dart';
import '../services/demo_academic_store.dart';
import '../services/profile_service.dart';
import '../widgets/app_states.dart';
import 'academic_dashboard_screen.dart';
import 'login_screen.dart';
import 'student_portal_screen.dart';
import 'teacher_dashboard_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool demoLoggedIn = false;
  int revision = 0;
  void demoLogin(String role) {
    DemoAcademicStore.instance.activeRole = role;
    setState(() {
      demoLoggedIn = true;
      revision++;
    });
  }

  void demoLogout() => setState(() => demoLoggedIn = false);
  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    if (config.useSupabase) {
      return StreamBuilder<AuthState>(
          stream: Supabase.instance.client.auth.onAuthStateChange,
          builder: (_, __) {
            if (Supabase.instance.client.auth.currentSession == null)
              return const LoginScreen();
            return _RoleRouter(
                key: ValueKey(
                    '${Supabase.instance.client.auth.currentUser?.id}-$revision'));
          });
    }
    if (!demoLoggedIn) return LoginScreen(onDemoLogin: demoLogin);
    return _RoleRouter(key: ValueKey(revision), onDemoLogout: demoLogout);
  }
}

class _RoleRouter extends StatefulWidget {
  const _RoleRouter({super.key, this.onDemoLogout});
  final VoidCallback? onDemoLogout;
  @override
  State<_RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<_RoleRouter> {
  late Future<Profile> profile;
  @override
  void initState() {
    super.initState();
    profile = ProfileService(useSupabase: context.read<AppConfig>().useSupabase)
        .currentProfile();
  }

  void retry() => setState(() => profile =
      ProfileService(useSupabase: context.read<AppConfig>().useSupabase)
          .currentProfile());
  void logout() {
    if (context.read<AppConfig>().useSupabase) {
      Supabase.instance.client.auth.signOut();
    } else {
      widget.onDemoLogout?.call();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Profile>(
      future: profile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Scaffold(
              body: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Preparando tu espacio académico...')
          ])));
        if (snapshot.hasError)
          return Scaffold(
              appBar: AppBar(actions: [
                IconButton(onPressed: logout, icon: const Icon(Icons.logout))
              ]),
              body: ErrorState(
                  message: friendlyError(snapshot.error!), retry: retry));
        final p = snapshot.data!;
        if (p.role == UserRole.docente) {
          if (p.teacherId == null)
            return _MissingLink(role: 'docente', logout: logout);
          return TeacherDashboardScreen(
              profile: p, onDemoLogout: widget.onDemoLogout);
        }
        if (p.role == UserRole.estudiante) {
          if (p.studentId == null)
            return _MissingLink(role: 'estudiante', logout: logout);
          return StudentPortalScreen(
              profile: p, onDemoLogout: widget.onDemoLogout);
        }
        return AcademicDashboardScreen(
            profile: p, onDemoLogout: widget.onDemoLogout);
      });
}

class _MissingLink extends StatelessWidget {
  const _MissingLink({required this.role, required this.logout});
  final String role;
  final VoidCallback logout;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout))
        ]),
        body: EmptyState(
            icon: Icons.link_off,
            title: 'Perfil $role sin vinculación',
            message:
                'Un administrador debe vincular esta cuenta con su registro académico.'));
  }
}
