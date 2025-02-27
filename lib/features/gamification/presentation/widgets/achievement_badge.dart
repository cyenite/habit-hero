import 'package:flutter/material.dart';
import 'package:habit_tracker/features/gamification/domain/models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;
  final bool showDetails;

  const AchievementBadge({
    Key? key,
    required this.achievement,
    this.onTap,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: achievement.unlocked
              ? achievement.color.withOpacity(0.2)
              : colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: achievement.unlocked
                ? achievement.color.withOpacity(0.5)
                : colorScheme.outline.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: achievement.unlocked
                    ? achievement.color.withOpacity(0.2)
                    : colorScheme.surfaceVariant.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                color: achievement.unlocked
                    ? achievement.color
                    : colorScheme.onSurfaceVariant.withOpacity(0.6),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),

            // Badge name
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: achievement.unlocked
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),

            if (showDetails) ...[
              const SizedBox(height: 8),

              // Description
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 8),

              // XP reward
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: achievement.unlocked
                        ? Colors.amber
                        : colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${achievement.xpReward} XP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: achievement.unlocked
                          ? Colors.amber
                          : colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              if (!achievement.unlocked)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Locked',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
