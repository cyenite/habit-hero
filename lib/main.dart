import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/app/app.dart';
import 'package:habit_tracker/core/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.initialize();

  runApp(
    const ProviderScope(
      child: HabitTrackerApp(),
    ),
  );
}
