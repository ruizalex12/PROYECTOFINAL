import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/app_brand.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _ocultar = true;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final success =
        await auth.signIn(correo: _correo.text, contrasena: _contrasena.text);
    if (!mounted || !success) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      auth.isAdmin ? RouteNames.admin : RouteNames.docente,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9FCFB), Color(0xFFEAF4F1), Color(0xFFDCECE7)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              return Stack(
                children: [
                  const Positioned(
                      top: -180,
                      right: -120,
                      child: _Circle(size: 520, color: Color(0x54FFFFFF))),
                  const Positioned(
                      bottom: -250,
                      left: -80,
                      child: _Circle(size: 600, color: Color(0x2D0E8977))),
                  Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: wide ? 48 : 20, vertical: 28),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: wide
                            ? Row(
                                children: [
                                  const Expanded(child: _WelcomePanel()),
                                  const SizedBox(width: 64),
                                  SizedBox(
                                      width: 440,
                                      child: _LoginCard(
                                          auth: auth,
                                          formKey: _formKey,
                                          correo: _correo,
                                          contrasena: _contrasena,
                                          ocultar: _ocultar,
                                          onToggleVisibility: () => setState(
                                              () => _ocultar = !_ocultar),
                                          onSubmit: _submit)),
                                ],
                              )
                            : Column(
                                children: [
                                  const AppBrand(),
                                  const SizedBox(height: 28),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 460),
                                    child: _LoginCard(
                                        auth: auth,
                                        formKey: _formKey,
                                        correo: _correo,
                                        contrasena: _contrasena,
                                        ocultar: _ocultar,
                                        onToggleVisibility: () => setState(
                                            () => _ocultar = !_ocultar),
                                        onSubmit: _submit),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBrand(),
            const SizedBox(height: 44),
            Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 22),
            Text(
                'Formación integral para un servicio\nen la Iglesia y la sociedad.',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: AppColors.muted, height: 1.45)),
            const SizedBox(height: 54),
            Container(
              height: 220,
              constraints: const BoxConstraints(maxWidth: 550),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary]),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: .18),
                      blurRadius: 35,
                      offset: const Offset(0, 18))
                ],
              ),
              child: const Stack(
                children: [
                  Positioned(
                      right: 34,
                      top: 24,
                      child: Icon(Icons.church_outlined,
                          size: 120, color: Colors.white12)),
                  Positioned(
                      left: 34,
                      bottom: 30,
                      child: Icon(Icons.auto_stories_rounded,
                          size: 88, color: Colors.white)),
                  Positioned(
                      left: 138,
                      bottom: 46,
                      child: Text('Conocimiento • Servicio • Fe',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ],
        ),
      );
}

class _LoginCard extends StatelessWidget {
  const _LoginCard(
      {required this.auth,
      required this.formKey,
      required this.correo,
      required this.contrasena,
      required this.ocultar,
      required this.onToggleVisibility,
      required this.onSubmit});

  final AuthController auth;
  final GlobalKey<FormState> formKey;
  final TextEditingController correo;
  final TextEditingController contrasena;
  final bool ocultar;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding:
              EdgeInsets.all(MediaQuery.sizeOf(context).width < 500 ? 24 : 36),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                        color: Color(0xFFE7F2EF), shape: BoxShape.circle),
                    child: const Icon(Icons.person_outline_rounded,
                        size: 36, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 22),
                Text('Iniciar sesión',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Ingrese sus credenciales para acceder al sistema.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, height: 1.4)),
                const SizedBox(height: 28),
                TextFormField(
                  controller: correo,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.mail_outline_rounded)),
                  validator: (value) =>
                      value == null || !value.trim().contains('@')
                          ? 'Ingrese un correo válido.'
                          : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contrasena,
                  obscureText: ocultar,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => onSubmit(),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                        onPressed: onToggleVisibility,
                        tooltip: ocultar
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        icon: Icon(ocultar
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined)),
                  ),
                  validator: (value) => value == null || value.length < 6
                      ? 'Ingrese al menos 6 caracteres.'
                      : null,
                ),
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 9),
                          Expanded(child: Text(auth.errorMessage!))
                        ]),
                  ),
                ],
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: auth.submitting ? null : onSubmit,
                  icon: auth.submitting
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.login_rounded),
                  label: Text(
                      auth.submitting ? 'Verificando...' : 'Iniciar sesión'),
                ),
                const SizedBox(height: 22),
                const Row(children: [
                  Expanded(child: Divider()),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Acceso para Administrador y Docente',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted))),
                  Expanded(child: Divider())
                ]),
              ],
            ),
          ),
        ),
      );
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
