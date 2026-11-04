import 'package:flutter/material.dart';

Future<DateTime?> showSpanishDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
}) =>
    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('es', 'BO'),
      helpText: helpText,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: ThemeData.from(
            colorScheme: theme.colorScheme,
            textTheme: theme.textTheme,
            useMaterial3: false,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
