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
        return 'Correo o contraseña incorrectos.';
      }
      return 'No fue posible iniciar sesión. Verifique sus datos.';
    }
    if (error is PostgrestException) {
      if (error.code == '23505') {
        return 'Ya existe un registro con esos datos.';
      }
      if (error.code == '23514' || error.code == '22P02') {
        return 'Los datos ingresados no son válidos.';
      }
      if (error.code == '401' || error.code == 'PGRST301') {
        return 'Su sesión no es válida o ha expirado.';
      }
      if (error.code == '403' ||
          error.code == '42501' ||
          error.code == 'PGRST302') {
        return 'No tiene permisos para realizar esta operación.';
      }
      if (error.code == 'PGRST205') {
        return 'El servicio solicitado todavía no está disponible.';
      }
      if (error.code == 'PGRST116') {
        return 'El recurso solicitado no fue encontrado.';
      }
      return 'No fue posible completar la operación solicitada.';
    }
    final text = error.toString().toLowerCase();
    if (text.contains('socket') ||
        text.contains('network') ||
        text.contains('failed to fetch') ||
        text.contains('clientexception')) {
      return 'No fue posible conectarse con el servidor.';
    }
    return 'Ocurrió un problema inesperado. Intente nuevamente.';
  }
}
