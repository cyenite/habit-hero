import 'package:flutter/material.dart';

class LevelIndicator extends StatelessWidget {
  final int level;
  final int xp;
  final int nextLevelXp;

  const LevelIndicator({
    super.key,
    required this.level,
    required this.xp,
    required this.nextLevelXp,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = xp / nextLevelXp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$xp / $nextLevelXp XP',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
