import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  })  : assert(currentPage >= 1),
        assert(totalPages >= 1),
        assert(currentPage <= totalPages);

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;
          if (compact) {
            return Semantics(
              label: 'Navegación de páginas',
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('pagination_previous'),
                      onPressed: currentPage == 1
                          ? null
                          : () => onPageChanged(currentPage - 1),
                      child: const Text('Anterior'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '$currentPage / $totalPages',
                      key: const Key('pagination_compact_label'),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('pagination_next'),
                      onPressed: currentPage == totalPages
                          ? null
                          : () => onPageChanged(currentPage + 1),
                      child: const Text('Siguiente'),
                    ),
                  ),
                ],
              ),
            );
          }
          return Semantics(
            label: 'Navegación de páginas',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  key: const Key('pagination_previous'),
                  onPressed: currentPage == 1
                      ? null
                      : () => onPageChanged(currentPage - 1),
                  child: const Text('Anterior'),
                ),
                const SizedBox(width: 8),
                ..._visiblePages().map(
                  (page) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: page == null
                        ? const SizedBox(
                            width: 28,
                            child: Center(child: Text('…')),
                          )
                        : page == currentPage
                            ? FilledButton(
                                key: Key('pagination_page_$page'),
                                onPressed: null,
                                style: FilledButton.styleFrom(
                                  disabledBackgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  disabledForegroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  minimumSize: const Size(42, 40),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text('$page'),
                              )
                            : TextButton(
                                key: Key('pagination_page_$page'),
                                onPressed: () => onPageChanged(page),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(42, 40),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text('$page'),
                              ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  key: const Key('pagination_next'),
                  onPressed: currentPage == totalPages
                      ? null
                      : () => onPageChanged(currentPage + 1),
                  child: const Text('Siguiente'),
                ),
              ],
            ),
          );
        },
      );

  List<int?> _visiblePages() {
    if (totalPages <= 7) {
      return [for (var page = 1; page <= totalPages; page++) page];
    }
    if (currentPage <= 4) return [1, 2, 3, 4, 5, null, totalPages];
    if (currentPage >= totalPages - 3) {
      return [
        1,
        null,
        totalPages - 4,
        totalPages - 3,
        totalPages - 2,
        totalPages - 1,
        totalPages
      ];
    }
    return [
      1,
      null,
      currentPage - 1,
      currentPage,
      currentPage + 1,
      null,
      totalPages
    ];
  }
}
