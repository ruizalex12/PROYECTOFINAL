import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onDemoLogin});
  final void Function(String role)? onDemoLogin;
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  static const studentEmail = 'estudiante@seminariotarija.edu',
      studentPassword = 'Estudiante2026*';
  static const teacherEmail = 'docente@seminariotarija.edu',
      teacherPassword = 'Docente2026*';
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController(text: studentEmail),
      password = TextEditingController(text: studentPassword);
  bool hidden = true, busy = false;
  String role = 'estudiante';
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void choose(String value) {
    setState(() {
      role = value;
      error = null;
      email.text = value == 'docente' ? teacherEmail : studentEmail;
      password.text = value == 'docente' ? teacherPassword : studentPassword;
    });
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (context.read<AppConfig>().useSupabase) {
        await AuthService(Supabase.instance.client)
            .signIn(email: email.text, password: password.text);
      } else {
        await Future.delayed(const Duration(milliseconds: 350));
        widget.onDemoLogin?.call(role);
      }
    } on AuthException catch (e) {
      if (mounted)
        setState(() => error = e.message == 'Invalid login credentials'
            ? 'Correo o contraseña incorrectos.'
            : e.message);
    } catch (_) {
      if (mounted)
        setState(
            () => error = 'No fue posible conectar con el servicio académico.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final demo = !context.watch<AppConfig>().useSupabase;
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            Color(0xFF06123A),
            Color(0xFF142263),
            Color(0xFFB78B2D)
          ])),
      child: SafeArea(
          child: Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 470),
                      child: Card(
                          child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: _content(context, demo))))))),
    ));
  }

  Widget _content(BuildContext context, bool demo) => Form(
      key: formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
            child: Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF8F5E9),
                    border:
                        Border.all(color: const Color(0xFFD4AF37), width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 16)
                    ]),
                child: const Icon(Icons.account_balance_rounded,
                    size: 64, color: Color(0xFF071A52)))),
        const SizedBox(height: 18),
        const Text('PORTAL ACADÉMICO',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
                color: Color(0xFF071A52))),
        const Text('Seminario Tarija',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: Colors.black54)),
        const SizedBox(height: 22),
        SegmentedButton<String>(segments: const [
          ButtonSegment(
              value: 'estudiante',
              icon: Icon(Icons.school_outlined),
              label: Text('Estudiante')),
          ButtonSegment(
              value: 'docente',
              icon: Icon(Icons.co_present_outlined),
              label: Text('Docente'))
        ], selected: {
          role
        }, onSelectionChanged: (v) => choose(v.first)),
        const SizedBox(height: 20),
        TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.mail_outline)),
            validator: (v) => v == null || !v.contains('@')
                ? 'Ingresa un correo válido'
                : null),
        const SizedBox(height: 14),
        TextFormField(
            controller: password,
            obscureText: hidden,
            onFieldSubmitted: (_) => login(),
            decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                    onPressed: () => setState(() => hidden = !hidden),
                    icon: Icon(hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined))),
            validator: (v) =>
                v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null),
        if (error != null) ...[
          const SizedBox(height: 12),
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.error_outline),
                const SizedBox(width: 8),
                Expanded(child: Text(error!))
              ]))
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF071A72),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: busy ? null : login,
            icon: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.login),
            label: Text(busy ? 'VALIDANDO...' : 'INGRESAR',
                style: const TextStyle(fontWeight: FontWeight.bold))),
        TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Solicita una nueva contraseña a Secretaría Académica.'))),
            child: const Text('¿Olvidaste tu contraseña?')),
        const Divider(),
        Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF3F5FF),
                borderRadius: BorderRadius.circular(12)),
            child: Text(
                '${demo ? 'MODO DEMO · ' : ''}Acceso cargado automáticamente\n${role == 'docente' ? teacherEmail : studentEmail}\n${role == 'docente' ? teacherPassword : studentPassword}',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF33406C)))),
      ]));
}
