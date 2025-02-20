import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/core/config/supabase_config.dart';

class ServiceLocator {
  static Future<void> initialize() async {
    await SupabaseConfig.initialize();

    await Future.wait([
      SharedPreferences.getInstance(),
      Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      ),
    ]);
  }
}
