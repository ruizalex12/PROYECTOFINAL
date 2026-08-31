import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.demoMode});
  final bool demoMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.green.shade100,
      child: Text(
        demoMode
            ? 'MODO DEMO: la app corre sin Supabase. Los registros NO sobreviven al reinicio.'
            : 'MODO SUPABASE: autenticación + base de datos + RLS activas.',
        style: TextStyle(
          color: Colors.green.shade900,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
