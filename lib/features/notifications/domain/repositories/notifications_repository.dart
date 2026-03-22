import '../models/push_notification_item.dart';

abstract interface class NotificationsRepository {
  Stream<List<PushNotificationItem>> watchNotifications(String userId);

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  });

  Future<void> markAllAsRead(String userId);

  Future<void> pushLocal(PushNotificationItem item);

  Future<void> registerDeviceToken({
    required String userId,
    required String fcmToken,
  });
}
