import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/settings_item.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;

  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items.map((item) {
              return ListTile(
                leading: Icon(item.icon, color: colorScheme.primary, size: 20),
                title: Text(item.title),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: item.onTap,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
