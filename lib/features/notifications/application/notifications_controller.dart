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

final _lastSyncedPushKeyProvider = StateProvider<String?>((ref) => null);

final notificationsPushSyncProvider = FutureProvider<void>((ref) async {
  final userId = ref.watch(authControllerProvider).valueOrNull?.user?.id;
  final fcmToken = ref.watch(pushFcmTokenProvider);

  if (userId == null || fcmToken == null || fcmToken.isEmpty) {
    ref.read(_lastSyncedPushKeyProvider.notifier).state = null;
    ref.read(pushSyncErrorProvider.notifier).state = null;
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
  } catch (error) {
    ref.read(pushSyncErrorProvider.notifier).state = error.toString();
  }
});

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
}

final notificationsControllerProvider = Provider<NotificationsController>((
  ref,
) {
  return NotificationsController(ref);
});
