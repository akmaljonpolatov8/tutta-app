import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/runtime_flags.dart';
import '../../../core/network/api_client.dart';
import '../../auth/application/auth_controller.dart';
import '../../notifications/application/notifications_controller.dart';
import '../../notifications/domain/models/push_notification_item.dart';
import '../data/repositories/api_chat_repository.dart';
import '../data/repositories/fake_chat_repository.dart';
import '../domain/models/chat_thread.dart';
import '../domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  if (!RuntimeFlags.useFakeChat) {
    return ApiChatRepository(ref.watch(apiClientProvider));
  }
  return FakeChatRepository();
});

final realtimeChatThreadsProvider =
    StreamProvider.autoDispose<List<ChatThread>>((ref) {
      final userId = ref.watch(authControllerProvider).valueOrNull?.user?.id;
      if (userId == null) {
        return Stream<List<ChatThread>>.value(const <ChatThread>[]);
      }

      return ref.watch(chatRepositoryProvider).watchThreads(userId);
    });

class RealtimeChatController {
  const RealtimeChatController(this._ref);

  final Ref _ref;

  String? get _userId =>
      _ref.read(authControllerProvider).valueOrNull?.user?.id;

  Future<void> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final userId = _userId;
    if (userId == null || body.trim().isEmpty) {
      return;
    }

    await _ref
        .read(chatRepositoryProvider)
        .sendMessage(
          conversationId: conversationId,
          senderUserId: userId,
          body: body.trim(),
        );

    await _ref
        .read(notificationsControllerProvider)
        .pushLocal(
          title: 'Message sent',
          body: 'Your message was delivered in chat.',
          type: PushNotificationType.chat,
          deepLink: '/chat',
        );
  }

  Future<void> markThreadRead(String threadId) async {
    final userId = _userId;
    if (userId == null) {
      return;
    }

    await _ref
        .read(chatRepositoryProvider)
        .markThreadRead(userId: userId, threadId: threadId);
  }
}

final realtimeChatControllerProvider = Provider<RealtimeChatController>((ref) {
  return RealtimeChatController(ref);
});
