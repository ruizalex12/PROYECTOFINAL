import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../services/academic_service.dart';
import '../widgets/app_states.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _State();
}

class _State extends State<ReportsScreen> {
  late Future<Map<String, int>> future;
  @override
  void initState() {
    super.initState();
    future = Future.value({});
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  void load() => setState(() => future =
      AcademicService(useSupabase: context.read<AppConfig>().useSupabase)
          .dashboardCounts());
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Reportes académicos')),
      body: FutureBuilder<Map<String, int>>(
          future: future,
          builder: (c, s) {
            if (s.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (s.hasError) {
              return ErrorState(message: friendlyError(s.error!), retry: load);
            }
            return ListView(padding: const EdgeInsets.all(20), children: [
              Text('Resumen institucional',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...s.data!.entries.map((e) => Card(
                  child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.analytics)),
                      title: Text(e.key[0].toUpperCase() + e.key.substring(1)),
                      trailing: Text('${e.value}',
                          style: Theme.of(context).textTheme.headlineSmall))))
            ]);
          }));
}
