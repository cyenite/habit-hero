// Mocks generated by Mockito 5.4.4 from annotations
// in habit_tracker/test/mocks.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:habit_tracker/core/services/connectivity_service.dart' as _i12;
import 'package:habit_tracker/core/services/notification_service.dart' as _i11;
import 'package:habit_tracker/features/auth/data/repositories/auth_repository.dart'
    as _i4;
import 'package:habit_tracker/features/auth/data/repositories/social_auth_repository.dart'
    as _i6;
import 'package:habit_tracker/features/gamification/domain/models/achievement.dart'
    as _i8;
import 'package:habit_tracker/features/gamification/domain/models/challenge.dart'
    as _i9;
import 'package:habit_tracker/features/habits/data/repositories/habit_repository.dart'
    as _i7;
import 'package:habit_tracker/features/habits/data/repositories/local_storage_repository.dart'
    as _i10;
import 'package:habit_tracker/features/habits/domain/models/habit.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i13;
import 'package:supabase_flutter/supabase_flutter.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeAuthResponse_0 extends _i1.SmartFake implements _i2.AuthResponse {
  _FakeAuthResponse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeHabit_1 extends _i1.SmartFake implements _i3.Habit {
  _FakeHabit_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFunctionsClient_2 extends _i1.SmartFake
    implements _i2.FunctionsClient {
  _FakeFunctionsClient_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSupabaseStorageClient_3 extends _i1.SmartFake
    implements _i2.SupabaseStorageClient {
  _FakeSupabaseStorageClient_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRealtimeClient_4 extends _i1.SmartFake
    implements _i2.RealtimeClient {
  _FakeRealtimeClient_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePostgrestClient_5 extends _i1.SmartFake
    implements _i2.PostgrestClient {
  _FakePostgrestClient_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeGoTrueClient_6 extends _i1.SmartFake implements _i2.GoTrueClient {
  _FakeGoTrueClient_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSupabaseQueryBuilder_7 extends _i1.SmartFake
    implements _i2.SupabaseQueryBuilder {
  _FakeSupabaseQueryBuilder_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSupabaseQuerySchema_8 extends _i1.SmartFake
    implements _i2.SupabaseQuerySchema {
  _FakeSupabaseQuerySchema_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePostgrestFilterBuilder_9<T1> extends _i1.SmartFake
    implements _i2.PostgrestFilterBuilder<T1> {
  _FakePostgrestFilterBuilder_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRealtimeChannel_10 extends _i1.SmartFake
    implements _i2.RealtimeChannel {
  _FakeRealtimeChannel_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUser_11 extends _i1.SmartFake implements _i2.User {
  _FakeUser_11(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSession_12 extends _i1.SmartFake implements _i2.Session {
  _FakeSession_12(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [AuthRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthRepository extends _i1.Mock implements _i4.AuthRepository {
  MockAuthRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Stream<_i2.AuthState> get authStateChanges => (super.noSuchMethod(
        Invocation.getter(#authStateChanges),
        returnValue: _i5.Stream<_i2.AuthState>.empty(),
      ) as _i5.Stream<_i2.AuthState>);

  @override
  _i5.Future<_i2.AuthResponse> signUp({
    required String? email,
    required String? password,
    required String? name,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #signUp,
          [],
          {
            #email: email,
            #password: password,
            #name: name,
          },
        ),
        returnValue: _i5.Future<_i2.AuthResponse>.value(_FakeAuthResponse_0(
          this,
          Invocation.method(
            #signUp,
            [],
            {
              #email: email,
              #password: password,
              #name: name,
            },
          ),
        )),
      ) as _i5.Future<_i2.AuthResponse>);

  @override
  _i5.Future<_i2.AuthResponse> signIn({
    required String? email,
    required String? password,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #signIn,
          [],
          {
            #email: email,
            #password: password,
          },
        ),
        returnValue: _i5.Future<_i2.AuthResponse>.value(_FakeAuthResponse_0(
          this,
          Invocation.method(
            #signIn,
            [],
            {
              #email: email,
              #password: password,
            },
          ),
        )),
      ) as _i5.Future<_i2.AuthResponse>);

  @override
  _i5.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> restoreSession() => (super.noSuchMethod(
        Invocation.method(
          #restoreSession,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [SocialAuthRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockSocialAuthRepository extends _i1.Mock
    implements _i6.SocialAuthRepository {
  MockSocialAuthRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.AuthResponse> signInWithGoogle() => (super.noSuchMethod(
        Invocation.method(
          #signInWithGoogle,
          [],
        ),
        returnValue: _i5.Future<_i2.AuthResponse>.value(_FakeAuthResponse_0(
          this,
          Invocation.method(
            #signInWithGoogle,
            [],
          ),
        )),
      ) as _i5.Future<_i2.AuthResponse>);
}

/// A class which mocks [HabitRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockHabitRepository extends _i1.Mock implements _i7.HabitRepository {
  MockHabitRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<List<_i3.Habit>> getHabits() => (super.noSuchMethod(
        Invocation.method(
          #getHabits,
          [],
        ),
        returnValue: _i5.Future<List<_i3.Habit>>.value(<_i3.Habit>[]),
      ) as _i5.Future<List<_i3.Habit>>);

  @override
  _i5.Future<_i3.Habit?> getHabitById(String? id) => (super.noSuchMethod(
        Invocation.method(
          #getHabitById,
          [id],
        ),
        returnValue: _i5.Future<_i3.Habit?>.value(),
      ) as _i5.Future<_i3.Habit?>);

  @override
  _i5.Future<_i3.Habit> createHabit(_i3.Habit? habit) => (super.noSuchMethod(
        Invocation.method(
          #createHabit,
          [habit],
        ),
        returnValue: _i5.Future<_i3.Habit>.value(_FakeHabit_1(
          this,
          Invocation.method(
            #createHabit,
            [habit],
          ),
        )),
      ) as _i5.Future<_i3.Habit>);

  @override
  _i5.Future<_i3.Habit> updateHabit(_i3.Habit? habit) => (super.noSuchMethod(
        Invocation.method(
          #updateHabit,
          [habit],
        ),
        returnValue: _i5.Future<_i3.Habit>.value(_FakeHabit_1(
          this,
          Invocation.method(
            #updateHabit,
            [habit],
          ),
        )),
      ) as _i5.Future<_i3.Habit>);

  @override
  _i5.Future<void> deleteHabit(String? id) => (super.noSuchMethod(
        Invocation.method(
          #deleteHabit,
          [id],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> completeHabit(
    String? habitId, {
    String? notes,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #completeHabit,
          [habitId],
          {#notes: notes},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> uncompleteHabit(
    String? habitId,
    String? completionId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #uncompleteHabit,
          [
            habitId,
            completionId,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<_i3.HabitCompletion>> getCompletionsForHabit(
          String? habitId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCompletionsForHabit,
          [habitId],
        ),
        returnValue: _i5.Future<List<_i3.HabitCompletion>>.value(
            <_i3.HabitCompletion>[]),
      ) as _i5.Future<List<_i3.HabitCompletion>>);

  @override
  _i5.Future<List<_i3.HabitCompletion>> getCompletionsForDate(DateTime? date) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCompletionsForDate,
          [date],
        ),
        returnValue: _i5.Future<List<_i3.HabitCompletion>>.value(
            <_i3.HabitCompletion>[]),
      ) as _i5.Future<List<_i3.HabitCompletion>>);

  @override
  _i5.Future<List<_i8.Achievement>> getAchievements() => (super.noSuchMethod(
        Invocation.method(
          #getAchievements,
          [],
        ),
        returnValue:
            _i5.Future<List<_i8.Achievement>>.value(<_i8.Achievement>[]),
      ) as _i5.Future<List<_i8.Achievement>>);

  @override
  _i5.Future<List<_i8.Achievement>> getUnlockedAchievements() =>
      (super.noSuchMethod(
        Invocation.method(
          #getUnlockedAchievements,
          [],
        ),
        returnValue:
            _i5.Future<List<_i8.Achievement>>.value(<_i8.Achievement>[]),
      ) as _i5.Future<List<_i8.Achievement>>);

  @override
  _i5.Future<List<_i9.Challenge>> getDailyChallenges() => (super.noSuchMethod(
        Invocation.method(
          #getDailyChallenges,
          [],
        ),
        returnValue: _i5.Future<List<_i9.Challenge>>.value(<_i9.Challenge>[]),
      ) as _i5.Future<List<_i9.Challenge>>);

  @override
  _i5.Future<List<_i3.HabitCompletion>> getTodayCompletions() =>
      (super.noSuchMethod(
        Invocation.method(
          #getTodayCompletions,
          [],
        ),
        returnValue: _i5.Future<List<_i3.HabitCompletion>>.value(
            <_i3.HabitCompletion>[]),
      ) as _i5.Future<List<_i3.HabitCompletion>>);
}

/// A class which mocks [LocalStorageRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockLocalStorageRepository extends _i1.Mock
    implements _i10.LocalStorageRepository {
  MockLocalStorageRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> initialize() => (super.noSuchMethod(
        Invocation.method(
          #initialize,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<_i3.Habit>> getHabits() => (super.noSuchMethod(
        Invocation.method(
          #getHabits,
          [],
        ),
        returnValue: _i5.Future<List<_i3.Habit>>.value(<_i3.Habit>[]),
      ) as _i5.Future<List<_i3.Habit>>);

  @override
  _i5.Future<_i3.Habit?> getHabitById(String? id) => (super.noSuchMethod(
        Invocation.method(
          #getHabitById,
          [id],
        ),
        returnValue: _i5.Future<_i3.Habit?>.value(),
      ) as _i5.Future<_i3.Habit?>);

  @override
  _i5.Future<void> saveHabit(_i3.Habit? habit) => (super.noSuchMethod(
        Invocation.method(
          #saveHabit,
          [habit],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> updateHabit(_i3.Habit? habit) => (super.noSuchMethod(
        Invocation.method(
          #updateHabit,
          [habit],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> deleteHabit(String? id) => (super.noSuchMethod(
        Invocation.method(
          #deleteHabit,
          [id],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<_i3.HabitCompletion>> getAllCompletions() =>
      (super.noSuchMethod(
        Invocation.method(
          #getAllCompletions,
          [],
        ),
        returnValue: _i5.Future<List<_i3.HabitCompletion>>.value(
            <_i3.HabitCompletion>[]),
      ) as _i5.Future<List<_i3.HabitCompletion>>);

  @override
  _i5.Future<List<_i3.HabitCompletion>> getCompletionsForHabit(
          String? habitId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCompletionsForHabit,
          [habitId],
        ),
        returnValue: _i5.Future<List<_i3.HabitCompletion>>.value(
            <_i3.HabitCompletion>[]),
      ) as _i5.Future<List<_i3.HabitCompletion>>);

  @override
  _i5.Future<List<_i3.HabitCompletion>> getCompletionsForDate(DateTime? date) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCompletionsForDate,
          [date],
        ),
        returnValue: _i5.Future<List<_i3.HabitCompletion>>.value(
            <_i3.HabitCompletion>[]),
      ) as _i5.Future<List<_i3.HabitCompletion>>);

  @override
  _i5.Future<void> saveCompletion(_i3.HabitCompletion? completion) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveCompletion,
          [completion],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> deleteCompletion(String? id) => (super.noSuchMethod(
        Invocation.method(
          #deleteCompletion,
          [id],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> addToSyncQueue(
    String? operation,
    dynamic data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addToSyncQueue,
          [
            operation,
            data,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<Map<dynamic, dynamic>>> getSyncQueue() => (super.noSuchMethod(
        Invocation.method(
          #getSyncQueue,
          [],
        ),
        returnValue: _i5.Future<List<Map<dynamic, dynamic>>>.value(
            <Map<dynamic, dynamic>>[]),
      ) as _i5.Future<List<Map<dynamic, dynamic>>>);

  @override
  _i5.Future<void> clearSyncQueue() => (super.noSuchMethod(
        Invocation.method(
          #clearSyncQueue,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<T>> getAll<T>(String? boxName) => (super.noSuchMethod(
        Invocation.method(
          #getAll,
          [boxName],
        ),
        returnValue: _i5.Future<List<T>>.value(<T>[]),
      ) as _i5.Future<List<T>>);

  @override
  _i5.Future<void> save<T>(
    String? boxName,
    String? id,
    T? item,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #save,
          [
            boxName,
            id,
            item,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> updateHabitWithoutSync(_i3.Habit? habit) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateHabitWithoutSync,
          [habit],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> saveCompletionWithoutSync(_i3.HabitCompletion? completion) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveCompletionWithoutSync,
          [completion],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<Map<dynamic, dynamic>>> getSyncOperationsByType(
          String? operationType) =>
      (super.noSuchMethod(
        Invocation.method(
          #getSyncOperationsByType,
          [operationType],
        ),
        returnValue: _i5.Future<List<Map<dynamic, dynamic>>>.value(
            <Map<dynamic, dynamic>>[]),
      ) as _i5.Future<List<Map<dynamic, dynamic>>>);
}

/// A class which mocks [NotificationService].
///
/// See the documentation for Mockito's code generation for more information.
class MockNotificationService extends _i1.Mock
    implements _i11.NotificationService {
  MockNotificationService() {
    _i1.throwOnMissingStub(this);
  }
}

/// A class which mocks [ConnectivityService].
///
/// See the documentation for Mockito's code generation for more information.
class MockConnectivityService extends _i1.Mock
    implements _i12.ConnectivityService {
  MockConnectivityService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Stream<bool> get connectionStatus => (super.noSuchMethod(
        Invocation.getter(#connectionStatus),
        returnValue: _i5.Stream<bool>.empty(),
      ) as _i5.Stream<bool>);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<bool> isConnected() => (super.noSuchMethod(
        Invocation.method(
          #isConnected,
          [],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);
}

/// A class which mocks [SupabaseClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockSupabaseClient extends _i1.Mock implements _i2.SupabaseClient {
  MockSupabaseClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FunctionsClient get functions => (super.noSuchMethod(
        Invocation.getter(#functions),
        returnValue: _FakeFunctionsClient_2(
          this,
          Invocation.getter(#functions),
        ),
      ) as _i2.FunctionsClient);

  @override
  set functions(_i2.FunctionsClient? _functions) => super.noSuchMethod(
        Invocation.setter(
          #functions,
          _functions,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.SupabaseStorageClient get storage => (super.noSuchMethod(
        Invocation.getter(#storage),
        returnValue: _FakeSupabaseStorageClient_3(
          this,
          Invocation.getter(#storage),
        ),
      ) as _i2.SupabaseStorageClient);

  @override
  set storage(_i2.SupabaseStorageClient? _storage) => super.noSuchMethod(
        Invocation.setter(
          #storage,
          _storage,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.RealtimeClient get realtime => (super.noSuchMethod(
        Invocation.getter(#realtime),
        returnValue: _FakeRealtimeClient_4(
          this,
          Invocation.getter(#realtime),
        ),
      ) as _i2.RealtimeClient);

  @override
  set realtime(_i2.RealtimeClient? _realtime) => super.noSuchMethod(
        Invocation.setter(
          #realtime,
          _realtime,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.PostgrestClient get rest => (super.noSuchMethod(
        Invocation.getter(#rest),
        returnValue: _FakePostgrestClient_5(
          this,
          Invocation.getter(#rest),
        ),
      ) as _i2.PostgrestClient);

  @override
  set rest(_i2.PostgrestClient? _rest) => super.noSuchMethod(
        Invocation.setter(
          #rest,
          _rest,
        ),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, String> get headers => (super.noSuchMethod(
        Invocation.getter(#headers),
        returnValue: <String, String>{},
      ) as Map<String, String>);

  @override
  set headers(Map<String, String>? headers) => super.noSuchMethod(
        Invocation.setter(
          #headers,
          headers,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.GoTrueClient get auth => (super.noSuchMethod(
        Invocation.getter(#auth),
        returnValue: _FakeGoTrueClient_6(
          this,
          Invocation.getter(#auth),
        ),
      ) as _i2.GoTrueClient);

  @override
  _i2.SupabaseQueryBuilder from(String? table) => (super.noSuchMethod(
        Invocation.method(
          #from,
          [table],
        ),
        returnValue: _FakeSupabaseQueryBuilder_7(
          this,
          Invocation.method(
            #from,
            [table],
          ),
        ),
      ) as _i2.SupabaseQueryBuilder);

  @override
  _i2.SupabaseQuerySchema schema(String? schema) => (super.noSuchMethod(
        Invocation.method(
          #schema,
          [schema],
        ),
        returnValue: _FakeSupabaseQuerySchema_8(
          this,
          Invocation.method(
            #schema,
            [schema],
          ),
        ),
      ) as _i2.SupabaseQuerySchema);

  @override
  _i2.PostgrestFilterBuilder<T> rpc<T>(
    String? fn, {
    Map<String, dynamic>? params,
    dynamic get = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #rpc,
          [fn],
          {
            #params: params,
            #get: get,
          },
        ),
        returnValue: _FakePostgrestFilterBuilder_9<T>(
          this,
          Invocation.method(
            #rpc,
            [fn],
            {
              #params: params,
              #get: get,
            },
          ),
        ),
      ) as _i2.PostgrestFilterBuilder<T>);

  @override
  _i2.RealtimeChannel channel(
    String? name, {
    _i2.RealtimeChannelConfig? opts = const _i2.RealtimeChannelConfig(),
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #channel,
          [name],
          {#opts: opts},
        ),
        returnValue: _FakeRealtimeChannel_10(
          this,
          Invocation.method(
            #channel,
            [name],
            {#opts: opts},
          ),
        ),
      ) as _i2.RealtimeChannel);

  @override
  List<_i2.RealtimeChannel> getChannels() => (super.noSuchMethod(
        Invocation.method(
          #getChannels,
          [],
        ),
        returnValue: <_i2.RealtimeChannel>[],
      ) as List<_i2.RealtimeChannel>);

  @override
  _i5.Future<String> removeChannel(_i2.RealtimeChannel? channel) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeChannel,
          [channel],
        ),
        returnValue: _i5.Future<String>.value(_i13.dummyValue<String>(
          this,
          Invocation.method(
            #removeChannel,
            [channel],
          ),
        )),
      ) as _i5.Future<String>);

  @override
  _i5.Future<List<String>> removeAllChannels() => (super.noSuchMethod(
        Invocation.method(
          #removeAllChannels,
          [],
        ),
        returnValue: _i5.Future<List<String>>.value(<String>[]),
      ) as _i5.Future<List<String>>);

  @override
  _i5.Future<void> dispose() => (super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [User].
///
/// See the documentation for Mockito's code generation for more information.
class MockUser extends _i1.Mock implements _i2.User {
  MockUser() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: _i13.dummyValue<String>(
          this,
          Invocation.getter(#id),
        ),
      ) as String);

  @override
  Map<String, dynamic> get appMetadata => (super.noSuchMethod(
        Invocation.getter(#appMetadata),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);

  @override
  String get aud => (super.noSuchMethod(
        Invocation.getter(#aud),
        returnValue: _i13.dummyValue<String>(
          this,
          Invocation.getter(#aud),
        ),
      ) as String);

  @override
  String get createdAt => (super.noSuchMethod(
        Invocation.getter(#createdAt),
        returnValue: _i13.dummyValue<String>(
          this,
          Invocation.getter(#createdAt),
        ),
      ) as String);

  @override
  bool get isAnonymous => (super.noSuchMethod(
        Invocation.getter(#isAnonymous),
        returnValue: false,
      ) as bool);

  @override
  Map<String, dynamic> toJson() => (super.noSuchMethod(
        Invocation.method(
          #toJson,
          [],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
}

/// A class which mocks [Session].
///
/// See the documentation for Mockito's code generation for more information.
class MockSession extends _i1.Mock implements _i2.Session {
  MockSession() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get accessToken => (super.noSuchMethod(
        Invocation.getter(#accessToken),
        returnValue: _i13.dummyValue<String>(
          this,
          Invocation.getter(#accessToken),
        ),
      ) as String);

  @override
  String get tokenType => (super.noSuchMethod(
        Invocation.getter(#tokenType),
        returnValue: _i13.dummyValue<String>(
          this,
          Invocation.getter(#tokenType),
        ),
      ) as String);

  @override
  _i2.User get user => (super.noSuchMethod(
        Invocation.getter(#user),
        returnValue: _FakeUser_11(
          this,
          Invocation.getter(#user),
        ),
      ) as _i2.User);

  @override
  set expiresAt(int? _expiresAt) => super.noSuchMethod(
        Invocation.setter(
          #expiresAt,
          _expiresAt,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get isExpired => (super.noSuchMethod(
        Invocation.getter(#isExpired),
        returnValue: false,
      ) as bool);

  @override
  Map<String, dynamic> toJson() => (super.noSuchMethod(
        Invocation.method(
          #toJson,
          [],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);

  @override
  _i2.Session copyWith({
    String? accessToken,
    int? expiresIn,
    String? refreshToken,
    String? tokenType,
    String? providerToken,
    String? providerRefreshToken,
    _i2.User? user,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #copyWith,
          [],
          {
            #accessToken: accessToken,
            #expiresIn: expiresIn,
            #refreshToken: refreshToken,
            #tokenType: tokenType,
            #providerToken: providerToken,
            #providerRefreshToken: providerRefreshToken,
            #user: user,
          },
        ),
        returnValue: _FakeSession_12(
          this,
          Invocation.method(
            #copyWith,
            [],
            {
              #accessToken: accessToken,
              #expiresIn: expiresIn,
              #refreshToken: refreshToken,
              #tokenType: tokenType,
              #providerToken: providerToken,
              #providerRefreshToken: providerRefreshToken,
              #user: user,
            },
          ),
        ),
      ) as _i2.Session);
}
