import '../../domain/entities/usuario.dart';

class UsuarioFormValidator {
  const UsuarioFormValidator._();

  static String? nombres(String? value) => value == null || value.trim().isEmpty
      ? 'Ingrese los nombres del usuario.'
      : null;

  static String? apellidos(String? value) =>
      value == null || value.trim().isEmpty
          ? 'Ingrese los apellidos del usuario.'
          : null;

  static String? ci(String? value) => value == null || value.trim().isEmpty
      ? 'Ingrese el CI del usuario.'
      : null;

  static String? correo(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingrese el correo del usuario.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Ingrese un correo válido.';
    }
    return null;
  }

  static String? password(String? value) => (value ?? '').length < 8
      ? 'La contraseña debe tener al menos 8 caracteres.'
      : null;

  static String? confirmacion(String? value, String password) =>
      value != password ? 'Las contraseñas no coinciden.' : null;
  static String? especialidad(String? value) =>
      value == null || value.trim().isEmpty
          ? 'Ingrese la especialidad del docente.'
          : null;

  static String? fechaOpcional(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = DateTime.tryParse(text);
    if (parsed == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      return 'Seleccione una fecha válida.';
    }
    return null;
  }

  static String? sexoDocente(SexoUsuario? value) =>
      value != SexoUsuario.masculino && value != SexoUsuario.femenino
          ? 'Seleccione Masculino o Femenino.'
          : null;

  static String? fechaNacimientoDocente(String? value) {
    final optionalError = fechaOpcional(value);
    if (optionalError != null) return optionalError;
    return value == null || value.trim().isEmpty
        ? 'Seleccione la fecha de nacimiento.'
        : null;
  }
}
