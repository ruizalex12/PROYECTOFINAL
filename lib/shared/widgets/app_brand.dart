import 'package:flutter/material.dart';

class AppBrand extends StatelessWidget {
  const AppBrand({super.key, this.compact = false, this.light = false});

  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = light ? Colors.white : scheme.onSurface;
    final secondaryForeground =
        light ? Colors.white70 : scheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 42 : 58,
          height: compact ? 42 : 58,
          decoration: BoxDecoration(
            color: light
                ? Colors.white12
                : dark
                    ? scheme.primaryContainer.withValues(alpha: .45)
                    : const Color(0xFFE8F4F0),
            borderRadius: BorderRadius.circular(compact ? 12 : 16),
            border: Border.all(
              color: light ? Colors.white24 : scheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 4 : 5),
            child: Image.asset(
              'assets/images/logo_sfm_tarija.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel:
                  'Logo del Seminario de Formación Ministerial Tarija',
            ),
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
                    color: secondaryForeground,
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
