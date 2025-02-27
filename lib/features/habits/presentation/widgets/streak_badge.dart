import 'package:flutter/material.dart';

class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;

    if (streak >= 30) {
      badgeColor = Colors.purple;
    } else if (streak >= 14) {
      badgeColor = Colors.orange;
    } else if (streak >= 7) {
      badgeColor = Colors.green;
    } else if (streak > 0) {
      badgeColor = Colors.blue;
    } else {
      badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            color: badgeColor,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak days',
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
