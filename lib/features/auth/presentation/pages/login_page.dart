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
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final ingresoCorrecto = await auth.signIn(
      correo: _correo.text.trim(),
      contrasena: _contrasena.text,
    );

    if (!mounted || !ingresoCorrecto) return;
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  const AppBrand(),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 34, 32, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(
                              Icons.account_circle_outlined,
                              size: 62,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Iniciar sesión',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Ingrese sus credenciales para continuar',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.muted),
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: _correo,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                hintText: 'nombre@correo.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    !value.trim().contains('@')) {
                                  return 'Ingrese un correo válido.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _contrasena,
                              obscureText: _ocultarContrasena,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => _iniciarSesion(),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _ocultarContrasena
                                      ? 'Mostrar contraseña'
                                      : 'Ocultar contraseña',
                                  onPressed: () => setState(
                                    () => _ocultarContrasena =
                                        !_ocultarContrasena,
                                  ),
                                  icon: Icon(
                                    _ocultarContrasena
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.length < 6
                                      ? 'Ingrese al menos 6 caracteres.'
                                      : null,
                            ),
                            if (auth.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .errorContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 20,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(child: Text(auth.errorMessage!)),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed:
                                  auth.submitting ? null : _iniciarSesion,
                              child: auth.submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Ingresar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Acceso exclusivo para Administrador y Docente',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
