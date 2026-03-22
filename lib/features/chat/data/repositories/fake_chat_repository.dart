import 'dart:async';

import '../../domain/models/chat_thread.dart';
import '../../domain/repositories/chat_repository.dart';

class FakeChatRepository implements ChatRepository {
  final Map<String, List<ChatThread>> _threadsByUser =
      <String, List<ChatThread>>{};
  final Map<String, StreamController<List<ChatThread>>> _controllers =
      <String, StreamController<List<ChatThread>>>{};
  final Map<String, Timer> _timers = <String, Timer>{};

  @override
  Stream<List<ChatThread>> watchThreads(String userId) {
    final controller = _controllers.putIfAbsent(
      userId,
      () => StreamController<List<ChatThread>>.broadcast(),
    );

    _threadsByUser.putIfAbsent(
      userId,
      () => <ChatThread>[
        ChatThread(
          id: 'c1',
          title: 'Marcus Henderson',
          lastMessage: 'Can you share a photo of the entrance?',
          lastMessageAt: DateTime.now().subtract(const Duration(minutes: 6)),
          unreadCount: 2,
        ),
        ChatThread(
          id: 'c2',
          title: 'Rosewood Host Team',
          lastMessage: 'Check-in details are ready.',
          lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
          unreadCount: 0,
        ),
      ],
    );

    Future<void>.microtask(
      () => controller.add(List<ChatThread>.from(_threadsByUser[userId]!)),
    );

    _timers.putIfAbsent(
      userId,
      () => Timer.periodic(const Duration(seconds: 12), (_) {
        final current = _threadsByUser[userId]!;
        if (current.isEmpty) {
          return;
        }
        final first = current.first.copyWith(
          lastMessage: 'Host: We have just prepared your room.',
          lastMessageAt: DateTime.now(),
          unreadCount: current.first.unreadCount + 1,
        );
        _threadsByUser[userId] = <ChatThread>[first, ...current.skip(1)];
        controller.add(List<ChatThread>.from(_threadsByUser[userId]!));
      }),
    );

    return controller.stream;
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderUserId,
    required String body,
  }) async {
    final current = _threadsByUser[senderUserId] ?? const <ChatThread>[];
    final updated = current
        .map((thread) {
          if (thread.id != conversationId) {
            return thread;
          }

          return thread.copyWith(
            lastMessage: body,
            lastMessageAt: DateTime.now(),
          );
        })
        .toList(growable: false);

    _threadsByUser[senderUserId] = updated;
    _controllers[senderUserId]?.add(List<ChatThread>.from(updated));
  }

  @override
  Future<void> markThreadRead({
    required String userId,
    required String threadId,
  }) async {
    final current = _threadsByUser[userId] ?? const <ChatThread>[];
    final updated = current
        .map((thread) {
          if (thread.id != threadId) {
            return thread;
          }

          return thread.copyWith(unreadCount: 0);
        })
        .toList(growable: false);

    _threadsByUser[userId] = updated;
    _controllers[userId]?.add(List<ChatThread>.from(updated));
  }
}
