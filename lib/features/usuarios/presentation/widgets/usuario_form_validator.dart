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
}
