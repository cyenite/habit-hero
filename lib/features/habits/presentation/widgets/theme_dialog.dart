import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/theme_provider.dart';

class ThemeDialog extends ConsumerWidget {
  const ThemeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SimpleDialog(
      title: const Text('Choose Theme'),
      children: [
        for (final theme in ThemeMode.values)
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
              Navigator.pop(context);
            },
            child: Text(theme.name.toUpperCase()),
          ),
      ],
    );
  }
}
