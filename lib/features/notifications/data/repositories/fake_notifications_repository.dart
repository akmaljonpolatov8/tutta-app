import 'dart:async';

import '../../domain/models/push_notification_item.dart';
import '../../domain/repositories/notifications_repository.dart';

class FakeNotificationsRepository implements NotificationsRepository {
  final Map<String, List<PushNotificationItem>> _itemsByUser =
      <String, List<PushNotificationItem>>{};
  final Map<String, String> _deviceTokenByUser = <String, String>{};
  final Map<String, StreamController<List<PushNotificationItem>>> _controllers =
      <String, StreamController<List<PushNotificationItem>>>{};
  final Map<String, Timer> _timers = <String, Timer>{};

  @override
  Stream<List<PushNotificationItem>> watchNotifications(String userId) {
    final controller = _controllers.putIfAbsent(
      userId,
      () => StreamController<List<PushNotificationItem>>.broadcast(),
    );

    _itemsByUser.putIfAbsent(userId, () => _seed(userId));
    Future<void>.microtask(
      () => controller.add(
        List<PushNotificationItem>.from(_itemsByUser[userId]!),
      ),
    );

    _timers.putIfAbsent(
      userId,
      () => Timer.periodic(const Duration(seconds: 14), (_) {
        final event = PushNotificationItem(
          id: 'n_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          title: 'Booking update',
          body: 'Host confirmed your request. Continue to payment.',
          type: PushNotificationType.booking,
          deepLink: '/bookings',
          createdAt: DateTime.now(),
          isRead: false,
        );
        _itemsByUser[userId] = <PushNotificationItem>[
          event,
          ..._itemsByUser[userId]!,
        ];
        controller.add(List<PushNotificationItem>.from(_itemsByUser[userId]!));
      }),
    );

    return controller.stream;
  }

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    final items = _itemsByUser[userId] ?? const <PushNotificationItem>[];
    _itemsByUser[userId] = items
        .map(
          (item) =>
              item.id == notificationId ? item.copyWith(isRead: true) : item,
        )
        .toList(growable: false);

    _controllers[userId]?.add(
      List<PushNotificationItem>.from(_itemsByUser[userId]!),
    );
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final items = _itemsByUser[userId] ?? const <PushNotificationItem>[];
    _itemsByUser[userId] = items
        .map((item) => item.copyWith(isRead: true))
        .toList(growable: false);

    _controllers[userId]?.add(
      List<PushNotificationItem>.from(_itemsByUser[userId]!),
    );
  }

  @override
  Future<void> pushLocal(PushNotificationItem item) async {
    final userId = item.userId;
    _itemsByUser.putIfAbsent(userId, () => _seed(userId));
    _itemsByUser[userId] = <PushNotificationItem>[
      item,
      ..._itemsByUser[userId]!,
    ];
    _controllers[userId]?.add(
      List<PushNotificationItem>.from(_itemsByUser[userId]!),
    );
  }

  @override
  Future<void> registerDeviceToken({
    required String userId,
    required String fcmToken,
  }) async {
    _deviceTokenByUser[userId] = fcmToken;
  }

  List<PushNotificationItem> _seed(String userId) {
    return <PushNotificationItem>[
      PushNotificationItem(
        id: 'n_seed_1',
        userId: userId,
        title: 'Welcome to Tutta',
        body: 'Enable alerts for booking and chat updates.',
        type: PushNotificationType.system,
        deepLink: '/home',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ];
  }
}
