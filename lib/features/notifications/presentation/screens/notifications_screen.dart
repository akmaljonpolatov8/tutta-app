import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../application/notifications_controller.dart';
import '../../domain/models/push_notification_item.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsControllerProvider).markAllAsRead();
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: asyncItems.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                tileColor: item.isRead
                    ? null
                    : Theme.of(context).colorScheme.primaryContainer,
                leading: Icon(_iconFor(item.type)),
                title: Text(item.title),
                subtitle: Text(item.body),
                trailing: Text(_timeAgo(item.createdAt)),
                onTap: () async {
                  await ref
                      .read(notificationsControllerProvider)
                      .markAsRead(item.id);
                  if (!context.mounted) {
                    return;
                  }
                  _openDeepLink(context, item.deepLink);
                },
              );
            },
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemCount: items.length,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  IconData _iconFor(PushNotificationType type) {
    return switch (type) {
      PushNotificationType.booking => Icons.calendar_today_outlined,
      PushNotificationType.chat => Icons.chat_bubble_outline,
      PushNotificationType.payment => Icons.payments_outlined,
      PushNotificationType.system => Icons.notifications_outlined,
    };
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) {
      return 'now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours}h';
    }
    return '${diff.inDays}d';
  }

  void _openDeepLink(BuildContext context, String deepLink) {
    if (deepLink.startsWith(RouteNames.bookings)) {
      context.go(RouteNames.bookings);
      return;
    }

    if (deepLink.startsWith(RouteNames.chatList)) {
      context.go(RouteNames.chatList);
      return;
    }

    context.go(RouteNames.home);
  }
}
