import '../models/chat_thread.dart';

abstract interface class ChatRepository {
  Stream<List<ChatThread>> watchThreads(String userId);

  Future<void> sendMessage({
    required String conversationId,
    required String senderUserId,
    required String body,
  });

  Future<void> markThreadRead({
    required String userId,
    required String threadId,
  });
}
