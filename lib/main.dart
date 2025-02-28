import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/app/app.dart';
import 'package:habit_tracker/core/services/service_locator.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Hive.initFlutter();
    await ServiceLocator.initialize();
    await NotificationService.initialize();
    await Firebase.initializeApp();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      log('Flutter error caught: ${details.exception}');
    };

    runApp(
      const ProviderScope(
        child: HabitTrackerApp(),
      ),
    );
  }, (error, stack) {
    log('Uncaught error: $error');
    log('Stack trace: $stack');
  });
}
