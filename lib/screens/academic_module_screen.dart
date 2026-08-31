import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/academic_module.dart';
import '../services/academic_service.dart';
import '../widgets/app_states.dart';

class AcademicModuleScreen extends StatefulWidget {
  const AcademicModuleScreen({super.key, required this.module});
  final AcademicModule module;
  @override
  State<AcademicModuleScreen> createState() => _AcademicModuleScreenState();
}

class _AcademicModuleScreenState extends State<AcademicModuleScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  AcademicService get service =>
      AcademicService(useSupabase: context.read<AppConfig>().useSupabase);
  @override
  void initState() {
    super.initState();
    _future = Future.value([]);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  void _reload() => setState(() => _future = service.list(widget.module.table));
  String _title(Map<String, dynamic> row) => widget.module.fields
      .take(2)
      .map((f) => row[f.key]?.toString() ?? '')
      .where((v) => v.isNotEmpty)
      .join(' · ');
  Future<void> _form([Map<String, dynamic>? row]) async {
    final controls = {
      for (final f in widget.module.fields)
        f.key: TextEditingController(text: row?[f.key]?.toString() ?? '')
    };
    final formKey = GlobalKey<FormState>();
    String? dialogError;
    var dialogBusy = false;
    final saved = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
            builder: (dialogContext, setDialogState) => AlertDialog(
                    title: Text(row == null
                        ? 'Nuevo ${widget.module.singular}'
                        : 'Editar ${widget.module.singular}'),
                    content: SizedBox(
                        width: 480,
                        child: Form(
                            key: formKey,
                            child: SingleChildScrollView(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                  for (final f in widget.module.fields)
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: TextFormField(
                                            controller: controls[f.key],
                                            keyboardType: f.numeric
                                                ? TextInputType.number
                                                : TextInputType.text,
                                            decoration: InputDecoration(
                                                labelText: f.label),
                                            validator: (v) => f.required &&
                                                    (v == null ||
                                                        v.trim().isEmpty)
                                                ? 'Campo requerido'
                                                : null)),
                                  if (dialogError != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Text(dialogError!,
                                          style: TextStyle(
                                              color: Theme.of(dialogContext)
                                                  .colorScheme
                                                  .error)),
                                    )
                                ])))),
                    actions: [
                      TextButton(
                          onPressed: dialogBusy
                              ? null
                              : () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancelar')),
                      FilledButton(
                          onPressed: dialogBusy
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setDialogState(() {
                                    dialogBusy = true;
                                    dialogError = null;
                                  });
                                  final values = <String, dynamic>{
                                    for (final f in widget.module.fields)
                                      f.key: f.numeric
                                          ? num.tryParse(controls[f.key]!.text)
                                          : controls[f.key]!.text.trim()
                                  };
                                  try {
                                    await service.save(
                                        widget.module.table, values,
                                        id: row?['id']?.toString());
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext, true);
                                    }
                                  } catch (error) {
                                    if (dialogContext.mounted) {
                                      setDialogState(() {
                                        dialogBusy = false;
                                        dialogError = friendlyError(error);
                                      });
                                    }
                                  }
                                },
                          child: Text(dialogBusy ? 'Guardando...' : 'Guardar'))
                    ])));
    if (saved == true && mounted) {
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(row == null
              ? '${widget.module.singular} guardado correctamente.'
              : '${widget.module.singular} actualizado correctamente.')));
    }
    for (final c in controls.values) c.dispose();
  }

  Future<void> _delete(Map<String, dynamic> row) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Confirmar eliminación'),
                content:
                    Text('¿Deseas eliminar este ${widget.module.singular}?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Eliminar'))
                ]));
    if (ok == true) {
      try {
        await service.remove(widget.module.table, row['id'].toString());
        if (mounted) {
          _reload();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registro eliminado.')));
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(friendlyError(error))));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(widget.module.title)),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _form(),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return ErrorState(
                  message: friendlyError(snapshot.error!), retry: _reload);
            final rows = snapshot.data ?? [];
            if (rows.isEmpty)
              return Center(
                  child:
                      Text('Aún no hay ${widget.module.title.toLowerCase()}'));
            return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final row = rows[index];
                  return Card(
                      child: ListTile(
                          leading:
                              CircleAvatar(child: Icon(widget.module.icon)),
                          title: Text(_title(row),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(widget.module.fields
                              .skip(2)
                              .map((f) => '${f.label}: ${row[f.key] ?? '-'}')
                              .join('  •  ')),
                          trailing: PopupMenuButton<String>(
                              onSelected: (v) =>
                                  v == 'edit' ? _form(row) : _delete(row),
                              itemBuilder: (_) => const [
                                    PopupMenuItem(
                                        value: 'edit', child: Text('Editar')),
                                    PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Eliminar'))
                                  ])));
                });
          }));
}
