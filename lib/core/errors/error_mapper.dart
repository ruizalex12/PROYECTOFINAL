import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

class ErrorMapper {
  const ErrorMapper._();

  static String message(Object error) {
    if (error is AppException) return error.message;

    if (error is FormatException) {
      return 'El perfil no tiene un rol autorizado.';
    }

    if (error is AuthException) {
      if (error.message.toLowerCase().contains('invalid login credentials')) {
        return 'Correo o contrasena incorrectos.';
      }
      return 'No fue posible iniciar sesion. Verifique sus datos.';
    }

    if (error is PostgrestException) {
      if (error.code == '23505') {
        return 'Ya existe una asignatura con ese codigo.';
      }
      if (error.code == '401' ||
          error.code == '403' ||
          error.code == '42501' ||
          error.code == 'PGRST301') {
        return 'No tiene permisos para realizar esta operacion.';
      }
      if (error.code == 'PGRST205') {
        return 'El servicio solicitado todavia no esta disponible.';
      }
      return 'No fue posible completar la operacion solicitada.';
    }

    final text = error.toString().toLowerCase();
    if (text.contains('socket') ||
        text.contains('network') ||
        text.contains('failed to fetch') ||
        text.contains('clientexception')) {
      return 'No fue posible conectarse con el servidor.';
    }

    return 'Ocurrio un problema inesperado. Intente nuevamente.';
  }
}
