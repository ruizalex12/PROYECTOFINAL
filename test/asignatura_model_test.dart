import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/asignaturas/data/models/asignatura_model.dart';

void main() {
  test('convierte una fila de Supabase en AsignaturaModel', () {
    final model = AsignaturaModel.fromMap({
      'id_asignatura': 7,
      'codigo': 'SFM-101',
      'nombre': 'Hermeneutica',
      'descripcion': 'Descripcion de prueba',
      'estado': true,
      'fecha_registro': '2026-09-25T12:00:00Z',
    });

    expect(model.id, 7);
    expect(model.codigo, 'SFM-101');
    expect(model.nombre, 'Hermeneutica');
    expect(model.estado, isTrue);
    expect(model.fechaRegistro.isUtc, isTrue);
  });
}
