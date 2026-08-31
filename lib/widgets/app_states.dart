import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.message});
  final IconData icon;
  final String title, message;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center)
          ])));
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.retry});
  final String message;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_rounded, size: 58),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
                onPressed: retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'))
          ])));
}

String friendlyError(Object error) {
  final text = error.toString();
  if (text.contains('PGRST205') || text.contains('schema cache'))
    return 'La tabla todavía no existe en Supabase. Ejecuta las migraciones SQL 01, 02 y 03.';
  if (text.contains('PGRST204') || text.contains('column'))
    return 'La base de datos no tiene todas las columnas requeridas. Ejecuta la migración SQL pendiente.';
  if (text.contains('duplicate') || text.contains('23505'))
    return 'Ese registro ya existe.';
  if (text.contains('permission') ||
      text.contains('row-level security') ||
      text.contains('42501'))
    return 'No tienes permisos para realizar esta acción.';
  if (text.contains('SocketException') || text.contains('ClientException'))
    return 'No se pudo conectar. Verifica tu conexión a Internet.';
  return text.replaceFirst('Exception: ', '').replaceFirst('Bad state: ', '');
}
