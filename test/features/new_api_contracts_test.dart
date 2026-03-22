import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutta/core/network/api_client.dart';
import 'package:tutta/core/network/api_endpoints.dart';
import 'package:tutta/core/network/api_result.dart';
import 'package:tutta/features/chat/data/repositories/api_chat_repository.dart';
import 'package:tutta/features/host_listing/data/repositories/api_host_listing_repository.dart';
import 'package:tutta/features/notifications/data/repositories/api_notifications_repository.dart';
import 'package:tutta/features/notifications/domain/models/push_notification_item.dart';
import 'package:tutta/features/profile_verification/data/repositories/api_profile_verification_repository.dart';

void main() {
  group('New API contracts', () {
    test('host listing upload contract', () async {
      final client = _RecordingApiClient();
      final repository = ApiHostListingRepository(client);

      client.queuePost(
        ApiSuccess(<String, dynamic>{
          'data': <String, dynamic>{'url': 'https://cdn.tutta/photo_1.jpg'},
        }),
      );

      final url = await repository.uploadPhoto(
        hostUserId: 'host-1',
        localPath: '/tmp/photo.jpg',
      );

      final call = client.postCalls.single;
      expect(call.path, ApiEndpoints.hostListingUpload('host-1'));
      expect(call.data?['localPath'], '/tmp/photo.jpg');
      expect(url, 'https://cdn.tutta/photo_1.jpg');
    });

    test('profile verification submit contract', () async {
      final client = _RecordingApiClient();
      final repository = ApiProfileVerificationRepository(client);

      client.queuePost(
        ApiSuccess(<String, dynamic>{
          'result': <String, dynamic>{
            'userId': 'u-1',
            'state': 'pending',
            'note': 'Submitted',
            'updatedAt': '2026-03-20T10:00:00.000Z',
          },
        }),
      );

      final status = await repository.submitVerification(
        userId: 'u-1',
        fullName: 'John Doe',
        documentId: 'AB12345',
        portfolioUrl: 'https://portfolio.dev/john',
      );

      final call = client.postCalls.single;
      expect(call.path, ApiEndpoints.profileVerification('u-1'));
      expect(call.data?['fullName'], 'John Doe');
      expect(status.state.name, 'pending');
    });

    test('chat send message contract', () async {
      final client = _RecordingApiClient();
      final repository = ApiChatRepository(client);

      client.queuePost(ApiSuccess(<String, dynamic>{'ok': true}));

      await repository.sendMessage(
        conversationId: 'c1',
        senderUserId: 'u-1',
        body: 'hello',
      );

      final call = client.postCalls.single;
      expect(call.path, ApiEndpoints.chatSendMessage('c1'));
      expect(call.data, <String, dynamic>{
        'senderUserId': 'u-1',
        'body': 'hello',
      });
    });

    test('notifications mark all read contract', () async {
      final client = _RecordingApiClient();
      final repository = ApiNotificationsRepository(client);

      client.queuePost(ApiSuccess(<String, dynamic>{'ok': true}));

      await repository.markAllAsRead('u-1');

      final call = client.postCalls.single;
      expect(call.path, ApiEndpoints.notificationsReadAll('u-1'));
    });

    test('notifications push local uses notifications endpoint', () async {
      final client = _RecordingApiClient();
      final repository = ApiNotificationsRepository(client);

      client.queuePost(ApiSuccess(<String, dynamic>{'ok': true}));

      await repository.pushLocal(
        PushNotificationItem(
          id: 'n1',
          userId: 'u-1',
          title: 'Title',
          body: 'Body',
          type: PushNotificationType.system,
          deepLink: '/home',
          createdAt: DateTime.parse('2026-03-20T10:00:00.000Z'),
          isRead: false,
        ),
      );

      final call = client.postCalls.single;
      expect(call.path, ApiEndpoints.notifications('u-1'));
      expect(call.data?['title'], 'Title');
    });

    test('notifications register device token contract', () async {
      final client = _RecordingApiClient();
      final repository = ApiNotificationsRepository(client);

      client.queuePost(ApiSuccess(<String, dynamic>{'ok': true}));

      await repository.registerDeviceToken(userId: 'u-1', fcmToken: 'tok_123');

      final call = client.postCalls.single;
      expect(call.path, ApiEndpoints.notificationsRegisterDevice('u-1'));
      expect(call.data?['fcmToken'], 'tok_123');
    });
  });
}

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(Dio());

  final List<_RecordedCall> getCalls = <_RecordedCall>[];
  final List<_RecordedCall> postCalls = <_RecordedCall>[];
  final List<ApiResult<Map<String, dynamic>>> _queuedGets =
      <ApiResult<Map<String, dynamic>>>[];
  final List<ApiResult<Map<String, dynamic>>> _queuedPosts =
      <ApiResult<Map<String, dynamic>>>[];

  void queueGet(ApiResult<Map<String, dynamic>> result) {
    _queuedGets.add(result);
  }

  void queuePost(ApiResult<Map<String, dynamic>> result) {
    _queuedPosts.add(result);
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    getCalls.add(
      _RecordedCall(
        path: path,
        data: null,
        queryParameters: queryParameters,
        headers: headers,
      ),
    );

    if (_queuedGets.isEmpty) {
      throw StateError('No queued GET response for $path');
    }
    return _queuedGets.removeAt(0);
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    postCalls.add(
      _RecordedCall(
        path: path,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
      ),
    );

    if (_queuedPosts.isEmpty) {
      throw StateError('No queued POST response for $path');
    }
    return _queuedPosts.removeAt(0);
  }
}

class _RecordedCall {
  const _RecordedCall({
    required this.path,
    required this.data,
    required this.queryParameters,
    required this.headers,
  });

  final String path;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? queryParameters;
  final Map<String, String>? headers;
}
