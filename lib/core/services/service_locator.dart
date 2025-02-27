import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/core/config/supabase_config.dart';
import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:habit_tracker/features/habits/data/repositories/local_storage_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker/core/services/connectivity_service.dart';
import 'package:habit_tracker/features/habits/data/repositories/sync_service.dart';

class ServiceLocator {
  static late ConnectivityService _connectivityService;
  static late SyncService _syncService;

  static ConnectivityService get connectivityService => _connectivityService;
  static SyncService get syncService => _syncService;

  static Future<void> initialize() async {
    dev.log('Initializing services');

    await Hive.initFlutter();
    await SupabaseConfig.initialize();
    await dotenv.load();
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    await SharedPreferences.getInstance();
    await LocalStorageRepository.instance.initialize();

    // Initialize connectivity service
    _connectivityService = ConnectivityService();

    // Initialize sync service after local storage is ready
    _syncService = SyncService(Supabase.instance.client,
        LocalStorageRepository.instance, _connectivityService);

    dev.log('Services initialized');
  }

  static void dispose() {
    _connectivityService.dispose();
    _syncService.dispose();
  }
}
