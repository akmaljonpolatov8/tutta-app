import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/runtime_flags.dart';
import '../../../core/network/api_client.dart';
import '../../auth/application/auth_controller.dart';
import '../data/repositories/api_notifications_repository.dart';
import '../data/repositories/fake_notifications_repository.dart';
import '../domain/models/push_notification_item.dart';
import '../domain/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  if (!RuntimeFlags.useFakeNotifications) {
    return ApiNotificationsRepository(ref.watch(apiClientProvider));
  }
  return FakeNotificationsRepository();
});

final notificationsStreamProvider =
    StreamProvider.autoDispose<List<PushNotificationItem>>((ref) {
      final userId = ref.watch(authControllerProvider).valueOrNull?.user?.id;
      if (userId == null) {
        return Stream<List<PushNotificationItem>>.value(
          const <PushNotificationItem>[],
        );
      }

      return ref
          .watch(notificationsRepositoryProvider)
          .watchNotifications(userId);
    });

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final items =
      ref.watch(notificationsStreamProvider).valueOrNull ??
      const <PushNotificationItem>[];
  return items.where((item) => !item.isRead).length;
});

final pushFcmTokenProvider = StateProvider<String?>((ref) => null);

final pushReadyProvider = StateProvider<bool>((ref) => false);

final pushSyncErrorProvider = StateProvider<String?>((ref) => null);

final pushAutoRetryEnabledProvider = Provider<bool>((ref) => true);

final pushAutoRetryMaxAttemptsProvider = Provider<int>((ref) => 5);

final pushSyncBackoffAttemptProvider = StateProvider<int>((ref) => 0);

final pushSyncRetryingProvider = StateProvider<bool>((ref) => false);

final pushSyncAutoRetryExhaustedProvider = StateProvider<bool>((ref) => false);

final _pushSyncRetryScheduleVersionProvider = StateProvider<int>((ref) => 0);

final _lastSyncedPushKeyProvider = StateProvider<String?>((ref) => null);

final _pushSyncRetryNonceProvider = StateProvider<int>((ref) => 0);

final _authUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull?.user?.id;
});

final notificationsAuthScopeSyncProvider = Provider<void>((ref) {
  ref.listen<String?>(_authUserIdProvider, (previous, next) {
    if (previous == next) {
      return;
    }

    ref.read(_lastSyncedPushKeyProvider.notifier).state = null;
    ref.read(pushSyncErrorProvider.notifier).state = null;
    ref.read(pushSyncBackoffAttemptProvider.notifier).state = 0;
    ref.read(pushSyncRetryingProvider.notifier).state = false;
    ref.read(pushSyncAutoRetryExhaustedProvider.notifier).state = false;
    ref
        .read(_pushSyncRetryScheduleVersionProvider.notifier)
        .update((state) => state + 1);
    ref.read(_pushSyncRetryNonceProvider.notifier).state = 0;

    if (next == null) {
      ref.read(pushFcmTokenProvider.notifier).state = null;
      ref.read(pushReadyProvider.notifier).state = false;
    }
  });
});

final notificationsPushSyncProvider = FutureProvider<void>((ref) async {
  ref.watch(_pushSyncRetryNonceProvider);
  final userId = ref.watch(authControllerProvider).valueOrNull?.user?.id;
  final fcmToken = ref.watch(pushFcmTokenProvider);

  if (userId == null || fcmToken == null || fcmToken.isEmpty) {
    ref.read(_lastSyncedPushKeyProvider.notifier).state = null;
    ref.read(pushSyncErrorProvider.notifier).state = null;
    ref.read(pushSyncBackoffAttemptProvider.notifier).state = 0;
    ref.read(pushSyncRetryingProvider.notifier).state = false;
    ref.read(pushSyncAutoRetryExhaustedProvider.notifier).state = false;
    return;
  }

  final syncKey = '$userId::$fcmToken';
  final lastSyncedKey = ref.read(_lastSyncedPushKeyProvider);
  if (lastSyncedKey == syncKey) {
    return;
  }

  try {
    await ref
        .watch(notificationsRepositoryProvider)
        .registerDeviceToken(userId: userId, fcmToken: fcmToken);
    ref.read(_lastSyncedPushKeyProvider.notifier).state = syncKey;
    ref.read(pushSyncErrorProvider.notifier).state = null;
    ref.read(pushSyncBackoffAttemptProvider.notifier).state = 0;
    ref.read(pushSyncRetryingProvider.notifier).state = false;
    ref.read(pushSyncAutoRetryExhaustedProvider.notifier).state = false;
  } catch (error) {
    ref.read(pushSyncErrorProvider.notifier).state = error.toString();

    final attempt = ref
        .read(pushSyncBackoffAttemptProvider.notifier)
        .update((state) => state + 1);
    final autoRetryEnabled = ref.read(pushAutoRetryEnabledProvider);
    final maxAttempts = ref.read(pushAutoRetryMaxAttemptsProvider);
    final shouldSchedule = pushSyncShouldScheduleAutoRetry(
      attempt: attempt,
      maxAttempts: maxAttempts,
    );

    if (!autoRetryEnabled || !shouldSchedule) {
      ref.read(pushSyncRetryingProvider.notifier).state = false;
      ref.read(pushSyncAutoRetryExhaustedProvider.notifier).state =
          autoRetryEnabled && !shouldSchedule;
      return;
    }

    ref.read(pushSyncAutoRetryExhaustedProvider.notifier).state = false;
    ref.read(pushSyncRetryingProvider.notifier).state = true;
    final scheduleVersion = ref.read(_pushSyncRetryScheduleVersionProvider);
    await Future<void>.delayed(pushSyncRetryDelayForAttempt(attempt));

    final stillValid = pushSyncRetryScheduleStillValid(
      scheduledVersion: scheduleVersion,
      currentVersion: ref.read(_pushSyncRetryScheduleVersionProvider),
    );
    if (!stillValid) {
      ref.read(pushSyncRetryingProvider.notifier).state = false;
      return;
    }

    ref.read(pushSyncRetryingProvider.notifier).state = false;

    final currentUserId = ref
        .read(authControllerProvider)
        .valueOrNull
        ?.user
        ?.id;
    final currentToken = ref.read(pushFcmTokenProvider);
    final hasError = ref.read(pushSyncErrorProvider) != null;
    if (hasError && currentUserId == userId && currentToken == fcmToken) {
      ref
          .read(_pushSyncRetryNonceProvider.notifier)
          .update((state) => state + 1);
    }
  }
});

Duration pushSyncRetryDelayForAttempt(int attempt) {
  final safeAttempt = attempt <= 0 ? 1 : attempt;
  final seconds = 1 << (safeAttempt - 1);
  final clampedSeconds = seconds > 32 ? 32 : seconds;
  return Duration(seconds: clampedSeconds);
}

bool pushSyncShouldScheduleAutoRetry({
  required int attempt,
  required int maxAttempts,
}) {
  if (maxAttempts <= 0) {
    return false;
  }
  return attempt <= maxAttempts;
}

bool pushSyncRetryScheduleStillValid({
  required int scheduledVersion,
  required int currentVersion,
}) {
  return scheduledVersion == currentVersion;
}

class NotificationsController {
  const NotificationsController(this._ref);

  final Ref _ref;

  String? get _userId =>
      _ref.read(authControllerProvider).valueOrNull?.user?.id;

  Future<void> markAsRead(String notificationId) async {
    final userId = _userId;
    if (userId == null) {
      return;
    }

    await _ref
        .read(notificationsRepositoryProvider)
        .markAsRead(userId: userId, notificationId: notificationId);
  }

  Future<void> markAllAsRead() async {
    final userId = _userId;
    if (userId == null) {
      return;
    }

    await _ref.read(notificationsRepositoryProvider).markAllAsRead(userId);
  }

  Future<void> pushLocal({
    required String title,
    required String body,
    required PushNotificationType type,
    required String deepLink,
  }) async {
    final userId = _userId;
    if (userId == null) {
      return;
    }

    final item = PushNotificationItem(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      body: body,
      type: type,
      deepLink: deepLink,
      createdAt: DateTime.now(),
      isRead: false,
    );

    await _ref.read(notificationsRepositoryProvider).pushLocal(item);
  }

  void retryPushSync() {
    _ref.read(pushSyncRetryingProvider.notifier).state = false;
    _ref.read(pushSyncBackoffAttemptProvider.notifier).state = 0;
    _ref.read(pushSyncAutoRetryExhaustedProvider.notifier).state = false;
    _ref
        .read(_pushSyncRetryScheduleVersionProvider.notifier)
        .update((state) => state + 1);
    _ref
        .read(_pushSyncRetryNonceProvider.notifier)
        .update((state) => state + 1);
  }
}

final notificationsControllerProvider = Provider<NotificationsController>((
  ref,
) {
  return NotificationsController(ref);
});
