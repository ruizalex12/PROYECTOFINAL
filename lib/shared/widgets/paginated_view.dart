import 'package:flutter/material.dart';

import 'pagination_bar.dart';

class PaginatedView<T> extends StatelessWidget {
  const PaginatedView({
    super.key,
    required this.items,
    required this.currentPage,
    required this.onPageChanged,
    required this.builder,
    this.pageSize = 10,
  });

  final List<T> items;
  final int currentPage;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final Widget Function(BuildContext context, List<T> pageItems) builder;

  @override
  Widget build(BuildContext context) {
    final totalPages = items.isEmpty ? 1 : (items.length / pageSize).ceil();
    final page = currentPage.clamp(1, totalPages);
    final start = (page - 1) * pageSize;
    final pageItems = items.skip(start).take(pageSize).toList(growable: false);
    return Column(
      children: [
        Expanded(child: builder(context, pageItems)),
        if (totalPages > 1) ...[
          const SizedBox(height: 16),
          PaginationBar(
            currentPage: page,
            totalPages: totalPages,
            onPageChanged: onPageChanged,
          ),
        ],
      ],
    );
  }
}
