import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/activity_card.dart';

class ActivityGrid extends StatelessWidget {
  const ActivityGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1,
      children: const [
        ActivityCard(
          title: 'Daily Tasks',
          value: '8/12',
          unit: 'completed',
          icon: Icons.check_circle_outline,
          color: Color(0xFF34C759), // Green
          progress: 0.66,
        ),
        ActivityCard(
          title: 'Focus Time',
          value: '2.5',
          unit: 'hours',
          icon: Icons.timer_outlined,
          color: Color(0xFF5856D6), // Purple
          progress: 0.5,
        ),
        ActivityCard(
          title: 'Reading',
          value: '45',
          unit: 'minutes',
          icon: Icons.book_outlined,
          color: Color(0xFF007AFF), // Blue
          progress: 0.75,
          showBarChart: true,
        ),
        ActivityCard(
          title: 'Meditation',
          value: '15',
          unit: 'minutes',
          icon: Icons.self_improvement,
          color: Color(0xFFFF9500), // Orange
          progress: 0.25,
        ),
      ],
    );
  }
}
