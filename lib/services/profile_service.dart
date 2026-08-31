import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/academic_entities.dart';
import 'demo_academic_store.dart';

class ProfileService {
  ProfileService({required this.useSupabase});
  final bool useSupabase;
  Future<Profile> currentProfile() async {
    if (!useSupabase)
      return DemoAcademicStore
          .instance.profiles[DemoAcademicStore.instance.activeRole]!;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null)
      throw StateError('Tu sesión ha expirado. Inicia sesión nuevamente.');
    final row = await Supabase.instance.client
        .from('perfiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (row == null)
      throw StateError('No existe un perfil académico asociado a esta cuenta.');
    final profile =
        Profile.fromMap({...row, 'email': row['email'] ?? user.email ?? ''});
    if (!['admin', 'docente', 'estudiante', 'administrador']
        .contains(row['rol']))
      throw StateError('El perfil no tiene un rol válido.');
    return profile;
  }
}
