enum PushNotificationType { booking, chat, payment, system }

class PushNotificationItem {
  const PushNotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.deepLink,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final PushNotificationType type;
  final String deepLink;
  final DateTime createdAt;
  final bool isRead;

  PushNotificationItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    PushNotificationType? type,
    String? deepLink,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return PushNotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      deepLink: deepLink ?? this.deepLink,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'deepLink': deepLink,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory PushNotificationItem.fromJson(Map<String, dynamic> json) {
    final rawType =
        (json['type'] as String?) ?? PushNotificationType.system.name;
    final type = PushNotificationType.values.firstWhere(
      (item) => item.name == rawType,
      orElse: () => PushNotificationType.system,
    );

    return PushNotificationItem(
      id: (json['id'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      type: type,
      deepLink: (json['deepLink'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      isRead: (json['isRead'] as bool?) ?? false,
    );
  }
}
