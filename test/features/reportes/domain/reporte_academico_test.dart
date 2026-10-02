import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/asistencia/domain/entities/asistencia.dart';
import 'package:proyecto_final_360/features/asistencias_admin/domain/entities/consulta_asistencia.dart';
import 'package:proyecto_final_360/features/calificaciones/domain/entities/calificacion.dart';
import 'package:proyecto_final_360/features/calificaciones_admin/domain/entities/consulta_calificacion.dart';
import 'package:proyecto_final_360/features/reportes/domain/entities/reporte_academico.dart';
import 'package:proyecto_final_360/features/reportes/domain/services/reporte_aggregation_service.dart';

void main() {
  group('regla académica', () {
    for (final value in [0.0, 50.0, 50.99]) {
      test(
          '$value es REPROBADO',
          () => expect(CalificacionRules.clasificar(value),
              ResultadoAcademico.reprobado));
    }
    for (final value in [51.0, 51.01, 79.0, 79.99]) {
      test(
          '$value es APROBADO',
          () => expect(CalificacionRules.clasificar(value),
              ResultadoAcademico.aprobado));
    }
    for (final value in [80.0, 80.01, 100.0]) {
      test(
          '$value es EXCELENTE',
          () => expect(CalificacionRules.clasificar(value),
              ResultadoAcademico.excelente));
    }
    test('rechaza valores fuera de 0–100', () {
      expect(() => CalificacionRules.clasificar(-.1), throwsArgumentError);
      expect(() => CalificacionRules.clasificar(100.1), throwsArgumentError);
    });
  });

  group('reporte de asistencia', () {
    test('agrupa y calcula presentes, ausentes, licencias, total y porcentaje',
        () {
      final rows = [
        _attendance(EstadoAsistencia.presente),
        _attendance(EstadoAsistencia.ausente),
        _attendance(EstadoAsistencia.licencia),
        _attendance(EstadoAsistencia.presente)
      ];
      final item = ReporteAggregationService.asistencia(rows).single;
      expect(item.presentes, 2);
      expect(item.ausentes, 1);
      expect(item.licencias, 1);
      expect(item.total, 4);
      expect(item.porcentaje, 50);
    });
    test('total cero evita división por cero', () {
      const item = ReporteAsistenciaItem(
          estudiante: 'A',
          asignatura: 'B',
          periodo: 'C',
          docente: 'D',
          presentes: 0,
          ausentes: 0,
          licencias: 0);
      expect(item.total, 0);
      expect(item.porcentaje, 0);
    });
  });

  group('reporte de calificaciones', () {
    test('agrupa cantidad, promedio, mínima, máxima y resultado', () {
      final item = ReporteAggregationService.calificaciones(
          [_grade(50), _grade(80), _grade(100)]).single;
      expect(item.evaluaciones, 3);
      expect(item.promedio, closeTo(76.666, .01));
      expect(item.minima, 50);
      expect(item.maxima, 100);
      expect(item.resultado, ResultadoAcademico.aprobado);
    });
    test('resumen clasifica promedios y calcula promedio general', () {
      final items = ReporteAggregationService.calificaciones([
        _grade(50, student: 1),
        _grade(60, student: 2),
        _grade(90, student: 3)
      ]);
      final summary = ReporteAggregationService.resumenCalificaciones(items);
      expect(summary.total, 3);
      expect(summary.reprobados, 1);
      expect(summary.aprobados, 1);
      expect(summary.excelentes, 1);
      expect(summary.promedioGeneral, closeTo(66.666, .01));
    });
    test('notas agrupadas mantienen escala 0–100', () {
      final item =
          ReporteAggregationService.calificaciones([_grade(0), _grade(100)])
              .single;
      expect(item.minima, 0);
      expect(item.maxima, 100);
    });
  });
}

ConsultaAsistencia _attendance(EstadoAsistencia state) => ConsultaAsistencia(
    id: state.index,
    fecha: DateTime(2026),
    fechaRegistro: DateTime(2026),
    estado: state,
    estudianteId: 1,
    estudianteNombre: 'Ana Uno',
    estudianteCi: '1',
    asignaturaId: 2,
    asignaturaNombre: 'Materia',
    periodoId: 3,
    periodoNombre: '2026',
    docenteId: 'd',
    docenteNombre: 'Docente');

ConsultaCalificacion _grade(double note, {int student = 1}) =>
    ConsultaCalificacion(
        id: student,
        fechaRegistro: DateTime(2026),
        tipoEvaluacion: 'EXAMEN',
        nota: note,
        estudianteId: student,
        estudianteNombre: 'Estudiante $student',
        estudianteCi: '$student',
        asignaturaId: 2,
        asignaturaNombre: 'Materia',
        periodoId: 3,
        periodoNombre: '2026',
        docenteId: 'd',
        docenteNombre: 'Docente');
