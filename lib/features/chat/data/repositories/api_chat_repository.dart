import 'dart:async';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/models/chat_thread.dart';
import '../../domain/repositories/chat_repository.dart';

class ApiChatRepository implements ChatRepository {
  const ApiChatRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Stream<List<ChatThread>> watchThreads(String userId) async* {
    while (true) {
      final result = await _apiClient.get(ApiEndpoints.chatThreads(userId));
      final threads = result.when(
        success: (data) => ApiResponseParser.extractList(
          data,
        ).map((item) => ChatThread.fromJson(item)).toList(growable: false),
        failure: _throwFailure,
      );

      yield threads;
      await Future<void>.delayed(const Duration(seconds: 6));
    }
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderUserId,
    required String body,
  }) async {
    final result = await _apiClient.post(
      ApiEndpoints.chatSendMessage(conversationId),
      data: <String, dynamic>{'senderUserId': senderUserId, 'body': body},
    );

    result.when(success: (_) => null, failure: _throwFailure);
  }

  @override
  Future<void> markThreadRead({
    required String userId,
    required String threadId,
  }) async {
    final result = await _apiClient.post(
      '${ApiEndpoints.chatThreads(userId)}/$threadId/read',
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
