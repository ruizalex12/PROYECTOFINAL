import '../../../asignaturas/data/models/asignatura_model.dart';
import '../../domain/entities/asignacion_docente.dart';

class AsignacionDocenteModel extends AsignacionDocente {
  const AsignacionDocenteModel({
    required super.id,
    required super.docenteId,
    required super.docenteNombre,
    required super.docenteCorreo,
    required super.asignatura,
    required super.periodo,
    required super.fechaAsignacion,
    required super.estado,
  });

  factory AsignacionDocenteModel.fromMap(Map<String, dynamic> map) {
    final asignatura = Map<String, dynamic>.from(map['asignatura'] as Map);
    final periodo = Map<String, dynamic>.from(map['periodo_academico'] as Map);
    final docente = Map<String, dynamic>.from(map['docente'] as Map);

    return AsignacionDocenteModel(
      id: (map['id_asignacion'] as num).toInt(),
      docenteId: docente['id'].toString(),
      docenteNombre: '${docente['nombres']} ${docente['apellidos']}'.trim(),
      docenteCorreo: docente['correo'].toString(),
      asignatura: AsignaturaModel.fromMap(asignatura),
      periodo: PeriodoAsignacion(
        id: (periodo['id_periodo'] as num).toInt(),
        nombre: periodo['nombre'].toString(),
        fechaInicio: DateTime.parse(periodo['fecha_inicio'].toString()),
        fechaFin: DateTime.parse(periodo['fecha_fin'].toString()),
        estado: periodo['estado'] == true,
      ),
      fechaAsignacion: DateTime.parse(map['fecha_asignacion'].toString()),
      estado: map['estado'] == true,
    );
  }
}
