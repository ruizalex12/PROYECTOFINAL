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

  static String? requiredSpecialty(String? value) =>
      value == null || value.trim().isEmpty
          ? 'Ingresa la especialidad del docente.'
          : null;

  static String? requiredSex(String? value) =>
      value != 'MASCULINO' && value != 'FEMENINO'
          ? 'Selecciona Masculino o Femenino.'
          : null;

  static String? requiredBirthDate(DateTime? value) =>
      value == null ? 'Selecciona la fecha de nacimiento.' : null;
}
