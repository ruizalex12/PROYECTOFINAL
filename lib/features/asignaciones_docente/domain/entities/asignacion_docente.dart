import '../../../asignaturas/domain/entities/asignatura.dart';

class PeriodoAsignacion {
  const PeriodoAsignacion({
    required this.id,
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
  });

  final int id;
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool estado;
}

class AsignacionDocente {
  const AsignacionDocente({
    required this.id,
    required this.docenteId,
    required this.docenteNombre,
    required this.docenteCorreo,
    required this.asignatura,
    required this.periodo,
    required this.fechaAsignacion,
    required this.estado,
  });

  final int id;
  final String docenteId;
  final String docenteNombre;
  final String docenteCorreo;
  final Asignatura asignatura;
  final PeriodoAsignacion periodo;
  final DateTime fechaAsignacion;
  final bool estado;
}

class DocenteOption {
  const DocenteOption({
    required this.id,
    required this.nombre,
    required this.correo,
  });

  final String id;
  final String nombre;
  final String correo;
}

class AsignaturaOption {
  const AsignaturaOption({
    required this.id,
    required this.codigo,
    required this.nombre,
  });

  final int id;
  final String codigo;
  final String nombre;
}

class PeriodoOption {
  const PeriodoOption({required this.id, required this.nombre});

  final int id;
  final String nombre;
}

class AsignacionDocenteOptions {
  const AsignacionDocenteOptions({
    required this.docentes,
    required this.asignaturas,
    required this.periodos,
  });

  final List<DocenteOption> docentes;
  final List<AsignaturaOption> asignaturas;
  final List<PeriodoOption> periodos;
}
