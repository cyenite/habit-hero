import 'package:flutter/material.dart';
import 'package:habit_tracker/features/gamification/domain/models/challenge.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: challenge.completed
              ? challenge.color.withOpacity(0.1)
              : colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: challenge.completed
                ? challenge.color.withOpacity(0.3)
                : colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: challenge.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    challenge.icon,
                    color: challenge.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Challenge',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        challenge.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: challenge.completed
                              ? challenge.color
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: challenge.completed
                        ? Colors.green.withOpacity(0.2)
                        : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        challenge.completed ? Icons.check : Icons.star,
                        size: 16,
                        color:
                            challenge.completed ? Colors.green : Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${challenge.xpReward} XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              challenge.completed ? Colors.green : Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              challenge.description,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (!challenge.completed)
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires at midnight',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
