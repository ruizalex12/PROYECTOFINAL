import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../asignaciones_docente/domain/entities/asignacion_docente.dart';
import '../../../asignaciones_docente/domain/repositories/asignacion_docente_repository.dart';
import '../../../asistencias_admin/domain/entities/consulta_asistencia.dart';
import '../../../asistencias_admin/domain/repositories/consulta_asistencia_repository.dart';
import '../../../calificaciones/domain/entities/calificacion.dart';
import '../../../calificaciones/domain/repositories/calificacion_repository.dart';
import '../../../estudiantes/domain/repositories/estudiante_repository.dart';
import '../../domain/entities/resumen_academico.dart';

enum ResumenAcademicoState { loading, empty, error, data }

class ResumenAcademicoController extends ChangeNotifier {
  ResumenAcademicoController(
    this._asignaciones,
    this._estudiantes,
    this._asistencias,
    this._calificaciones,
    this.asignacionId,
  );

  final AsignacionDocenteRepository _asignaciones;
  final EstudianteRepository _estudiantes;
  final ConsultaAsistenciaRepository _asistencias;
  final CalificacionRepository _calificaciones;
  final int asignacionId;

  ResumenAcademicoState _state = ResumenAcademicoState.loading;
  ResumenAcademico? _resumen;
  String? _errorMessage;

  ResumenAcademicoState get state => _state;
  ResumenAcademico? get resumen => _resumen;
  AsignacionDocente? get asignacion => _resumen?.asignacion;
  String? get errorMessage => _errorMessage;

  Future<void> cargar() async {
    _state = ResumenAcademicoState.loading;
    _resumen = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final propias = await _asignaciones.listarPropiasActivas();
      AsignacionDocente? asignacion;
      for (final item in propias) {
        if (item.id == asignacionId) {
          asignacion = item;
          break;
        }
      }
      if (asignacion == null) {
        throw const AppException(
          'La asignación no existe o no está autorizada.',
        );
      }

      final estudiantes = await _estudiantes.listarPorAsignacion(asignacionId);
      if (estudiantes.isEmpty) {
        _resumen = ResumenAcademico.construir(
          asignacion: asignacion,
          estudiantes: const [],
          asistencias: const [],
          calificaciones: const [],
        );
        _state = ResumenAcademicoState.empty;
        notifyListeners();
        return;
      }

      final resultados = await Future.wait<Object>([
        _asistencias.listar(
          AsistenciaAdminFilter(
            periodoId: asignacion.periodo.id,
            asignaturaId: asignacion.asignatura.id,
            docenteId: asignacion.docenteId,
          ),
        ),
        _calificaciones.listarPorAsignacion(asignacionId),
      ]);

      _resumen = ResumenAcademico.construir(
        asignacion: asignacion,
        estudiantes: estudiantes,
        asistencias: resultados[0] as List<ConsultaAsistencia>,
        calificaciones: resultados[1] as List<Calificacion>,
      );
      _state = ResumenAcademicoState.data;
    } catch (error) {
      _errorMessage = ErrorMapper.message(error);
      _state = ResumenAcademicoState.error;
    }
    notifyListeners();
  }
}
