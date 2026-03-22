import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutta/features/auth/application/auth_controller.dart';
import 'package:tutta/features/auth/application/auth_state.dart';
import 'package:tutta/features/auth/domain/models/auth_user.dart';
import 'package:tutta/features/auth/domain/repositories/auth_repository.dart';
import 'package:tutta/features/notifications/application/notifications_controller.dart';
import 'package:tutta/features/notifications/domain/models/push_notification_item.dart';
import 'package:tutta/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:tutta/features/premium/domain/models/subscription_plan.dart';

void main() {
  test('push sync retry delay grows exponentially and is capped', () {
    expect(pushSyncRetryDelayForAttempt(1), const Duration(seconds: 1));
    expect(pushSyncRetryDelayForAttempt(2), const Duration(seconds: 2));
    expect(pushSyncRetryDelayForAttempt(3), const Duration(seconds: 4));
    expect(pushSyncRetryDelayForAttempt(10), const Duration(seconds: 32));
  });

  test('push sync auto retry scheduling respects max attempts', () {
    expect(pushSyncShouldScheduleAutoRetry(attempt: 1, maxAttempts: 3), isTrue);
    expect(pushSyncShouldScheduleAutoRetry(attempt: 3, maxAttempts: 3), isTrue);
    expect(
      pushSyncShouldScheduleAutoRetry(attempt: 4, maxAttempts: 3),
      isFalse,
    );
    expect(
      pushSyncShouldScheduleAutoRetry(attempt: 1, maxAttempts: 0),
      isFalse,
    );
  });

  test('push sync scheduled retry validity matches version equality', () {
    expect(
      pushSyncRetryScheduleStillValid(scheduledVersion: 4, currentVersion: 4),
      isTrue,
    );
    expect(
      pushSyncRetryScheduleStillValid(scheduledVersion: 4, currentVersion: 5),
      isFalse,
    );
  });

  test(
    'notifications auth scope reset clears push state on sign out',
    () async {
      final repository = _CountingNotificationsRepository();
      late AuthController authController;

      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(repository),
          pushAutoRetryEnabledProvider.overrideWithValue(false),
          authControllerProvider.overrideWith((ref) {
            authController = AuthController(_NoopAuthRepository(), ref)
              ..state = AsyncValue<AuthState>.data(
                AuthState.initial().copyWith(user: _testUser('u-1')),
              );
            return authController;
          }),
        ],
      );
      addTearDown(container.dispose);

      container.read(notificationsAuthScopeSyncProvider);
      container.read(pushReadyProvider.notifier).state = true;
      container.read(pushFcmTokenProvider.notifier).state = 'tok_1';
      container.read(pushSyncErrorProvider.notifier).state = 'err';

      authController.state = const AsyncValue<AuthState>.data(
        AuthState.initial(),
      );
      await Future<void>.delayed(Duration.zero);

      expect(container.read(pushReadyProvider), isFalse);
      expect(container.read(pushFcmTokenProvider), isNull);
      expect(container.read(pushSyncErrorProvider), isNull);
    },
  );

  test('notifications push sync deduplicates same user/token pair', () async {
    final repository = _CountingNotificationsRepository();
    final authState = AsyncValue<AuthState>.data(
      AuthState.initial().copyWith(
        user: const AuthUser(
          id: 'u-1',
          phone: '+998901234567',
          displayName: 'User',
          subscriptionPlan: SubscriptionPlan.free,
          countryCode: 'UZ',
        ),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
        pushAutoRetryEnabledProvider.overrideWithValue(false),
        authControllerProvider.overrideWith((ref) {
          final controller = AuthController(_NoopAuthRepository(), ref);
          controller.state = authState;
          return controller;
        }),
      ],
    );
    addTearDown(container.dispose);

    container.read(pushFcmTokenProvider.notifier).state = 'tok_1';

    await container.read(notificationsPushSyncProvider.future);
    await container.read(notificationsPushSyncProvider.future);

    expect(repository.registerCalls, 1);

    container.read(pushFcmTokenProvider.notifier).state = 'tok_2';
    await container.read(notificationsPushSyncProvider.future);

    expect(repository.registerCalls, 2);
  });

  test(
    'notifications push sync re-registers token after user switch',
    () async {
      final repository = _CountingNotificationsRepository();
      late AuthController authController;

      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(repository),
          pushAutoRetryEnabledProvider.overrideWithValue(false),
          authControllerProvider.overrideWith((ref) {
            authController = AuthController(_NoopAuthRepository(), ref)
              ..state = AsyncValue<AuthState>.data(
                AuthState.initial().copyWith(user: _testUser('u-1')),
              );
            return authController;
          }),
        ],
      );
      addTearDown(container.dispose);

      container.read(notificationsAuthScopeSyncProvider);
      container.read(pushFcmTokenProvider.notifier).state = 'tok_shared';
      await container.read(notificationsPushSyncProvider.future);

      expect(repository.registerCalls, 1);

      authController.state = AsyncValue<AuthState>.data(
        AuthState.initial().copyWith(user: _testUser('u-2')),
      );
      await Future<void>.delayed(Duration.zero);
      container.refresh(notificationsPushSyncProvider);
      await container.read(notificationsPushSyncProvider.future);

      expect(repository.registerCalls, 2);
    },
  );

  test(
    'notifications push sync stores error and retries after manual trigger',
    () async {
      final repository = _CountingNotificationsRepository()..shouldThrow = true;
      final authState = AsyncValue<AuthState>.data(
        AuthState.initial().copyWith(
          user: const AuthUser(
            id: 'u-1',
            phone: '+998901234567',
            displayName: 'User',
            subscriptionPlan: SubscriptionPlan.free,
            countryCode: 'UZ',
          ),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(repository),
          pushAutoRetryEnabledProvider.overrideWithValue(false),
          authControllerProvider.overrideWith((ref) {
            final controller = AuthController(_NoopAuthRepository(), ref);
            controller.state = authState;
            return controller;
          }),
        ],
      );
      addTearDown(container.dispose);

      container.read(pushFcmTokenProvider.notifier).state = 'tok_1';
      await container.read(notificationsPushSyncProvider.future);

      expect(repository.registerCalls, 1);
      expect(container.read(pushSyncErrorProvider), isNotNull);
      expect(container.read(pushSyncBackoffAttemptProvider), 1);

      repository.shouldThrow = false;
      container.read(notificationsControllerProvider).retryPushSync();
      expect(container.read(pushSyncBackoffAttemptProvider), 0);
      expect(container.read(pushSyncRetryingProvider), isFalse);
      await container.read(notificationsPushSyncProvider.future);

      expect(repository.registerCalls, 2);
      expect(container.read(pushSyncErrorProvider), isNull);
    },
  );

  test(
    'notifications push sync marks exhausted when max auto-retry is reached and recovers after manual retry',
    () async {
      final repository = _CountingNotificationsRepository()..shouldThrow = true;
      final authState = AsyncValue<AuthState>.data(
        AuthState.initial().copyWith(user: _testUser('u-1')),
      );

      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(repository),
          pushAutoRetryEnabledProvider.overrideWithValue(true),
          pushAutoRetryMaxAttemptsProvider.overrideWithValue(0),
          authControllerProvider.overrideWith((ref) {
            final controller = AuthController(_NoopAuthRepository(), ref);
            controller.state = authState;
            return controller;
          }),
        ],
      );
      addTearDown(container.dispose);

      container.read(pushFcmTokenProvider.notifier).state = 'tok_1';
      await container.read(notificationsPushSyncProvider.future);

      expect(repository.registerCalls, 1);
      expect(container.read(pushSyncRetryingProvider), isFalse);
      expect(container.read(pushSyncAutoRetryExhaustedProvider), isTrue);
      expect(container.read(pushSyncBackoffAttemptProvider), 1);

      repository.shouldThrow = false;
      container.read(notificationsControllerProvider).retryPushSync();
      expect(container.read(pushSyncAutoRetryExhaustedProvider), isFalse);
      expect(container.read(pushSyncBackoffAttemptProvider), 0);

      await container.read(notificationsPushSyncProvider.future);

      expect(repository.registerCalls, 2);
      expect(container.read(pushSyncErrorProvider), isNull);
      expect(container.read(pushSyncAutoRetryExhaustedProvider), isFalse);
    },
  );
}

class _CountingNotificationsRepository implements NotificationsRepository {
  int registerCalls = 0;
  bool shouldThrow = false;

  @override
  Future<void> registerDeviceToken({
    required String userId,
    required String fcmToken,
  }) async {
    registerCalls += 1;
    if (shouldThrow) {
      throw StateError('Failed to register token');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {}

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {}

  @override
  Future<void> pushLocal(PushNotificationItem item) async {}

  @override
  Stream<List<PushNotificationItem>> watchNotifications(String userId) {
    return const Stream<List<PushNotificationItem>>.empty();
  }
}

class _NoopAuthRepository implements AuthRepository {
  @override
  Future<void> requestOtp({required String phone}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser> verifyOtp({required String phone, required String code}) {
    throw UnimplementedError();
  }
}

AuthUser _testUser(String id) {
  return AuthUser(
    id: id,
    phone: '+998901234567',
    displayName: 'User $id',
    subscriptionPlan: SubscriptionPlan.free,
    countryCode: 'UZ',
  );
}
