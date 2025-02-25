import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/core/config/supabase_config.dart';
import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:habit_tracker/features/habits/data/repositories/local_storage_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ServiceLocator {
  static Future<void> initialize() async {
    dev.log('Initializing services');

    // Initialize Hive first
    await Hive.initFlutter();

    await SupabaseConfig.initialize();
    await dotenv.load();
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    await SharedPreferences.getInstance();

    // Initialize local storage after Hive is ready
    await LocalStorageRepository.instance.initialize();

    dev.log('Services initialized');
  }
}
