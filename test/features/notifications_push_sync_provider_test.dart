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
  test(
    'notifications auth scope reset clears push state on sign out',
    () async {
      final repository = _CountingNotificationsRepository();
      late AuthController authController;

      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(repository),
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

      repository.shouldThrow = false;
      container.read(notificationsControllerProvider).retryPushSync();
      await container.read(notificationsPushSyncProvider.future);

      expect(repository.registerCalls, 2);
      expect(container.read(pushSyncErrorProvider), isNull);
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
