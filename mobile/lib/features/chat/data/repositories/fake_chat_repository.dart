import '../../domain/models/chat_thread.dart';
import '../../domain/models/message.dart';
import '../../domain/repositories/chat_repository.dart';

class FakeChatRepository implements ChatRepository {
  final List<ChatThread> _threads = <ChatThread>[
    ChatThread(
      id: '1',
      listingId: 'l1',
      guestUserId: 'user_demo_1',
      hostUserId: 'h1',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      lastMessage: null,
      unreadCount: 0,
    ),
  ];

  final Map<String, List<Message>> _messagesByThread = <String, List<Message>>{
    '1': <Message>[
      Message(
        id: 'm1',
        conversationId: '1',
        senderUserId: 'h1',
        body: 'Assalomu alaykum, check-in vaqti 14:00.',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Message(
        id: 'm2',
        conversationId: '1',
        senderUserId: 'user_demo_1',
        body: 'Rahmat, tushundim.',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
  };

  @override
  Future<List<ChatThread>> getThreads() async {
    return _threads
        .map(
          (thread) => ChatThread(
            id: thread.id,
            listingId: thread.listingId,
            guestUserId: thread.guestUserId,
            hostUserId: thread.hostUserId,
            createdAt: thread.createdAt,
            lastMessage: _messagesByThread[thread.id]?.last.body,
            unreadCount: thread.unreadCount,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<ChatThread> createOrGetThread({
    required String listingId,
    required String guestUserId,
    required String hostUserId,
  }) async {
    final existing = (await getThreads())
        .where((thread) {
          return thread.listingId == listingId &&
              thread.guestUserId == guestUserId &&
              thread.hostUserId == hostUserId;
        })
        .toList(growable: false);
    if (existing.isNotEmpty) {
      return existing.first;
    }

    final threadId = DateTime.now().millisecondsSinceEpoch.toString();
    _messagesByThread.putIfAbsent(threadId, () => <Message>[]);
    final created = ChatThread(
      id: threadId,
      listingId: listingId,
      guestUserId: guestUserId,
      hostUserId: hostUserId,
      createdAt: DateTime.now(),
      lastMessage: null,
      unreadCount: 0,
    );
    _threads.add(created);
    return created;
  }

  @override
  Future<List<Message>> getMessages(String threadId) async {
    return List<Message>.from(_messagesByThread[threadId] ?? const <Message>[]);
  }

  @override
  Future<Message> sendMessage({
    required String threadId,
    required String content,
  }) async {
    final list = _messagesByThread.putIfAbsent(threadId, () => <Message>[]);
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: threadId,
      senderUserId: 'user_demo_1',
      body: content,
      sentAt: DateTime.now(),
      isRead: false,
    );
    list.add(message);
    return message;
  }
}
