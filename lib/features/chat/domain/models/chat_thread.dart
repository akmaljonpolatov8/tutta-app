class ChatThread {
  const ChatThread({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  ChatThread copyWith({
    String? id,
    String? title,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return ChatThread(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      lastMessage: (json['lastMessage'] as String?) ?? '',
      lastMessageAt:
          DateTime.tryParse((json['lastMessageAt'] as String?) ?? '') ??
          DateTime.now(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}
