class DocenteFormValidator {
  const DocenteFormValidator._();

  static String? requiredNames(String? value) =>
      value == null || value.trim().isEmpty
          ? 'Ingresa los nombres del docente.'
          : null;

  static String? requiredLastNames(String? value) =>
      value == null || value.trim().isEmpty
          ? 'Ingresa los apellidos del docente.'
          : null;

  static String? requiredCi(String? value) =>
      value == null || value.trim().isEmpty
          ? 'Ingresa el CI del docente.'
          : null;
}
