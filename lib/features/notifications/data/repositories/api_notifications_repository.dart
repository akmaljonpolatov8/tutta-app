import 'dart:async';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/models/push_notification_item.dart';
import '../../domain/repositories/notifications_repository.dart';

class ApiNotificationsRepository implements NotificationsRepository {
  const ApiNotificationsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Stream<List<PushNotificationItem>> watchNotifications(String userId) async* {
    while (true) {
      final result = await _apiClient.get(ApiEndpoints.notifications(userId));
      final items = result.when(
        success: (data) => ApiResponseParser.extractList(data)
            .map((item) => PushNotificationItem.fromJson(item))
            .toList(growable: false),
        failure: _throwFailure,
      );

      yield items;
      await Future<void>.delayed(const Duration(seconds: 8));
    }
  }

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    final result = await _apiClient.post(
      ApiEndpoints.notificationRead(userId, notificationId),
    );
    result.when(success: (_) => null, failure: _throwFailure);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final result = await _apiClient.post(
      ApiEndpoints.notificationsReadAll(userId),
    );
    result.when(success: (_) => null, failure: _throwFailure);
  }

  @override
  Future<void> pushLocal(PushNotificationItem item) async {
    final result = await _apiClient.post(
      ApiEndpoints.notifications(item.userId),
      data: item.toJson(),
    );
    result.when(success: (_) => null, failure: _throwFailure);
  }

  @override
  Future<void> registerDeviceToken({
    required String userId,
    required String fcmToken,
  }) async {
    final result = await _apiClient.post(
      ApiEndpoints.notificationsRegisterDevice(userId),
      data: <String, dynamic>{'fcmToken': fcmToken},
    );
    result.when(success: (_) => null, failure: _throwFailure);
  }

  Never _throwFailure(Failure failure) {
    throw AppException(
      failure.message,
      code: failure.code,
      statusCode: failure.statusCode,
    );
  }
}
