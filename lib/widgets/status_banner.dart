import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.demoMode});

  final bool demoMode;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}