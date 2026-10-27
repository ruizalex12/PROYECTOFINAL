import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/shared/widgets/pagination_bar.dart';

void main() {
  testWidgets('deshabilita Anterior en primera página y navega con Siguiente',
      (tester) async {
    var selectedPage = 1;
    await tester.pumpWidget(_harness(
      currentPage: selectedPage,
      totalPages: 8,
      onPageChanged: (page) => selectedPage = page,
    ));

    final previous = tester
        .widget<OutlinedButton>(find.byKey(const Key('pagination_previous')));
    expect(previous.onPressed, isNull);
    expect(find.text('…'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pagination_next')));
    expect(selectedPage, 2);
  });

  testWidgets('deshabilita Siguiente en la última página', (tester) async {
    await tester.pumpWidget(_harness(
      currentPage: 8,
      totalPages: 8,
      onPageChanged: (_) {},
    ));
    final next =
        tester.widget<OutlinedButton>(find.byKey(const Key('pagination_next')));
    expect(next.onPressed, isNull);
  });

  testWidgets('en ancho pequeño conserva Anterior y Siguiente sin overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness(
      currentPage: 3,
      totalPages: 8,
      onPageChanged: (_) {},
    ));
    expect(find.text('Anterior'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);
    expect(find.byKey(const Key('pagination_compact_label')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _harness({
  required int currentPage,
  required int totalPages,
  required ValueChanged<int> onPageChanged,
}) =>
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: PaginationBar(
          currentPage: currentPage,
          totalPages: totalPages,
          onPageChanged: onPageChanged,
        ),
      ),
    );
