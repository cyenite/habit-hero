import 'package:mockito/annotations.dart';
import 'package:habit_tracker/features/auth/data/repositories/auth_repository.dart';
import 'package:habit_tracker/features/auth/data/repositories/social_auth_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/local_storage_repository.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/core/services/connectivity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([
  AuthRepository,
  SocialAuthRepository,
  HabitRepository,
  LocalStorageRepository,
  NotificationService,
  ConnectivityService,
  SupabaseClient,
  User,
  Session,
])
void main() {}
