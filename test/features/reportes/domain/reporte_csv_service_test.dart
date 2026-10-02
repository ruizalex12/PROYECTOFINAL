import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/reportes/domain/entities/reporte_academico.dart';
import 'package:proyecto_final_360/features/reportes/domain/services/reporte_csv_service.dart';

void main() {
  test('CSV exporta únicamente los resultados recibidos y escapa comillas', () {
    final export = ReporteCsvService.generar(
        TipoReporteAcademico.inscripciones,
        [
          ReporteInscripcionItem(
              id: 1,
              estudianteId: 1,
              estudiante: 'Ana "A"',
              codigo: 'E1',
              ci: '1',
              asignatura: 'Materia',
              periodo: '2026',
              fecha: DateTime(2026, 9, 30),
              estado: true)
        ],
        now: DateTime(2026, 9, 30));
    expect(export.fileName, 'reporte_inscripciones_20260930.csv');
    expect(export.content, contains('Ana ""A""'));
    expect(export.content, contains('ACTIVA'));
  });
}
