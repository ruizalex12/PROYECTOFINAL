import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/shared/widgets/paginated_view.dart';

void main() {
  testWidgets('muestra diez registros y cambia a la página siguiente',
      (tester) async {
    var page = 1;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(builder: (context, setState) {
          return PaginatedView<int>(
            items: List.generate(25, (index) => index + 1),
            currentPage: page,
            onPageChanged: (value) => setState(() => page = value),
            builder: (context, items) => ListView(
              children: [for (final item in items) Text('Registro $item')],
            ),
          );
        }),
      ),
    ));

    expect(find.text('Registro 1'), findsOneWidget);
    expect(find.text('Registro 10'), findsOneWidget);
    expect(find.text('Registro 11'), findsNothing);

    await tester.tap(find.byKey(const Key('pagination_next')));
    await tester.pump();
    expect(find.text('Registro 1'), findsNothing);
    expect(find.text('Registro 11'), findsOneWidget);
    expect(find.text('Registro 20'), findsOneWidget);
  });

  testWidgets('no muestra controles cuando existe una sola página',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PaginatedView<int>(
          items: const [1, 2, 3],
          currentPage: 1,
          onPageChanged: (_) {},
          builder: (context, items) => const SizedBox(),
        ),
      ),
    ));
    expect(find.byKey(const Key('pagination_next')), findsNothing);
  });
}
