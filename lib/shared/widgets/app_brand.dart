import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AppBrand extends StatelessWidget {
  const AppBrand({super.key, this.compact = false, this.light = false});

  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final foreground = light ? Colors.white : AppColors.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 42 : 58,
          height: compact ? 42 : 58,
          decoration: BoxDecoration(
            color: light ? Colors.white12 : const Color(0xFFE8F4F0),
            borderRadius: BorderRadius.circular(compact ? 12 : 16),
            border:
                Border.all(color: light ? Colors.white24 : AppColors.border),
          ),
          child: Icon(
            Icons.auto_stories_rounded,
            color: light ? Colors.white : AppColors.primary,
            size: compact ? 25 : 34,
          ),
        ),
        const SizedBox(width: 13),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                compact ? 'SFM Tarija' : 'Sistema de Gestión Académica',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 17 : 24,
                  height: 1.08,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 5),
                Text(
                  'Seminario de Formación Ministerial Tarija',
                  maxLines: 2,
                  style: TextStyle(
                    color: light ? Colors.white70 : AppColors.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
