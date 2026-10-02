import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/asistencia/domain/entities/asistencia.dart';
import 'package:proyecto_final_360/features/asistencias_admin/domain/entities/consulta_asistencia.dart';
import 'package:proyecto_final_360/features/asistencias_admin/presentation/widgets/asistencia_admin_detail_dialog.dart';
import 'package:proyecto_final_360/features/asistencias_admin/presentation/widgets/asistencia_admin_table.dart';

void main() {
  testWidgets('la tabla Admin solo expone Ver detalle', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AsistenciaAdminTable(items: [_item], onDetail: (_) {}),
      ),
    ));

    expect(find.text('Ver detalle'), findsOneWidget);
    expect(find.textContaining('Crear asistencia'), findsNothing);
    expect(find.textContaining('Editar asistencia'), findsNothing);
    expect(find.textContaining('Eliminar asistencia'), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('el detalle es de solo lectura', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: AsistenciaAdminDetailDialog(item: _item)),
    ));

    expect(find.byKey(const Key('detalle_asistencia_solo_lectura')),
        findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Cerrar'), findsOneWidget);
    expect(find.text('Guardar'), findsNothing);
  });
}

final _item = ConsultaAsistencia(
  id: 1,
  fecha: DateTime(2026, 9, 30),
  fechaRegistro: DateTime(2026, 9, 30, 10),
  estado: EstadoAsistencia.presente,
  observacion: 'Puntual',
  estudianteId: 1,
  estudianteCodigo: 'EST-1',
  estudianteNombre: 'Ana Flores',
  estudianteCi: 'CI-1',
  asignaturaId: 10,
  asignaturaNombre: 'Teología',
  periodoId: 10,
  periodoNombre: '2026-II',
  docenteId: 'doc-1',
  docenteNombre: 'Laura Ríos',
);
