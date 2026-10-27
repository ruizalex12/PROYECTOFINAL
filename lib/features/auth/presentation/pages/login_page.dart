import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? [
                    scheme.surface,
                    Theme.of(context).scaffoldBackgroundColor,
                    scheme.surfaceContainerLowest,
                  ]
                : const [
                    Color(0xFFF9FBFA),
                    Color(0xFFF1F7F5),
                    Color(0xFFEDF5F3),
                  ],
            stops: const [0, .62, 1],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _AcademicBackgroundPainter(),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 900;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(desktop ? 32 : 18),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: scheme.outlineVariant,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: dark
                                    ? Colors.black.withValues(alpha: .28)
                                    : const Color(0x1A0C3B31),
                                blurRadius: 42,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: desktop
                              ? SizedBox(
                                  height: 680,
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        flex: 11,
                                        child: _InstitutionalPhotoPanel(),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: _buildLoginPanel(auth),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      height: 220,
                                      child: _InstitutionalPhotoPanel(
                                        compact: true,
                                      ),
                                    ),
                                    _buildLoginPanel(auth),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPanel(AuthController auth) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: dark ? scheme.surfaceContainerLowest : const Color(0xFFFBFCFC),
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppBrand(),
          const SizedBox(height: 26),
          Card(
            elevation: 0,
            color: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: dark
                            ? scheme.primaryContainer.withValues(alpha: .55)
                            : const Color(0xFFE8F4F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.lock_person_outlined,
                        size: 29,
                        color: scheme.primary,
                      ),
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
                    Text(
                      'Ingrese sus credenciales para continuar',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _correo,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'nombre@sfm.test',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || !value.trim().contains('@')) {
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
                            () => _ocultarContrasena = !_ocultarContrasena,
                          ),
                          icon: Icon(
                            _ocultarContrasena
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 6
                          ? 'Ingrese al menos 6 caracteres.'
                          : null,
                    ),
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 9),
                            Expanded(child: Text(auth.errorMessage!)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: auth.submitting ? null : _iniciarSesion,
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
          const SizedBox(height: 16),
          Text(
            'Acceso exclusivo para Administrador y Docente',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstitutionalPhotoPanel extends StatelessWidget {
  const _InstitutionalPhotoPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/comunidad_academica.png',
            fit: BoxFit.cover,
            alignment: compact ? Alignment.center : const Alignment(.38, 0),
            filterQuality: FilterQuality.high,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x190C3B31),
                  Color(0x330C3B31),
                  Color(0xD90C3B31),
                ],
                stops: [0, .52, 1],
              ),
            ),
          ),
          Positioned(
            left: compact ? 20 : 32,
            right: compact ? 20 : 32,
            top: compact ? 18 : 30,
            child: const Align(
              alignment: Alignment.centerLeft,
              child: AppBrand(compact: true, light: true),
            ),
          ),
          Positioned(
            left: compact ? 20 : 36,
            right: compact ? 20 : 36,
            bottom: compact ? 18 : 38,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0676D),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Formación integral al servicio de la comunidad',
                  maxLines: compact ? 2 : 3,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 20 : 30,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Una gestión académica clara, segura y conectada.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
}

class _AcademicBackgroundPainter extends CustomPainter {
  const _AcademicBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final isCompact = size.width < 700;
    final primary = const Color(0xFF0C3B31);
    final turquoise = const Color(0xFF79CFD0);
    final coral = const Color(0xFFD0676D);

    final corner = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * (isCompact ? .72 : .34), 0)
      ..quadraticBezierTo(
        size.width * (isCompact ? .53 : .27),
        size.height * .19,
        0,
        size.height * (isCompact ? .25 : .48),
      )
      ..close();
    canvas.drawPath(
      corner,
      Paint()..color = primary.withValues(alpha: isCompact ? .055 : .075),
    );

    final coralGlow = Paint()
      ..shader = RadialGradient(
        colors: [coral.withValues(alpha: .09), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * .92, size.height * .12),
          radius: isCompact ? 150 : 250,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * .92, size.height * .12),
      isCompact ? 150 : 250,
      coralGlow,
    );

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = primary.withValues(alpha: .075);
    final arcCenter = Offset(-size.width * .03, size.height * .08);
    for (var index = 0; index < 4; index++) {
      canvas.drawCircle(
        arcCenter,
        (isCompact ? 92 : 140) + index * (isCompact ? 32 : 46),
        arcPaint,
      );
    }

    final pagePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = isCompact ? 2 : 2.5;
    for (var index = 0; index < 3; index++) {
      final baseline = size.height - 34 - (index * (isCompact ? 17 : 23));
      final page = Path()
        ..moveTo(-20, baseline)
        ..cubicTo(
          size.width * .20,
          baseline - (isCompact ? 25 : 38),
          size.width * .37,
          baseline + (isCompact ? 22 : 32),
          size.width * .55,
          baseline - 3,
        )
        ..cubicTo(
          size.width * .70,
          baseline - (isCompact ? 27 : 42),
          size.width * .86,
          baseline + (isCompact ? 18 : 28),
          size.width + 20,
          baseline - 8,
        );
      pagePaint.color = (index == 1 ? coral : turquoise).withValues(
        alpha: index == 1 ? .10 : .18,
      );
      canvas.drawPath(page, pagePaint);
    }

    final dotPaint = Paint()..color = primary.withValues(alpha: .07);
    final startX = size.width * (isCompact ? .80 : .88);
    final startY = size.height * .66;
    for (var row = 0; row < 5; row++) {
      for (var column = 0; column < 5; column++) {
        canvas.drawCircle(
          Offset(startX + column * 16, startY + row * 16),
          1.6,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AcademicBackgroundPainter oldDelegate) => false;
}
