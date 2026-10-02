import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/features/calificaciones_admin/domain/entities/consulta_calificacion.dart';
import 'package:proyecto_final_360/features/calificaciones_admin/presentation/widgets/calificacion_admin_detail_dialog.dart';
import 'package:proyecto_final_360/features/calificaciones_admin/presentation/widgets/calificacion_admin_table.dart';

void main() {
  testWidgets('tabla Admin solo expone Ver detalle', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: CalificacionAdminTable(items: [_item], onDetail: (_) {})),
    ));
    expect(find.text('Ver detalle'), findsOneWidget);
    expect(find.textContaining('Crear'), findsNothing);
    expect(find.textContaining('Editar'), findsNothing);
    expect(find.textContaining('Eliminar'), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('detalle es de solo lectura', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalificacionAdminDetailDialog(item: _item)),
    ));
    expect(find.byKey(const Key('detalle_calificacion_solo_lectura')),
        findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Cerrar'), findsOneWidget);
    expect(find.text('Guardar'), findsNothing);
  });
}

final _item = ConsultaCalificacion(
  id: 1,
  fechaRegistro: DateTime(2026, 9, 30),
  tipoEvaluacion: 'Parcial',
  nota: 95,
  observacion: 'Excelente',
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
