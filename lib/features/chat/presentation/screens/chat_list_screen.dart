import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../application/realtime_chat_controller.dart';
import '../../domain/models/chat_thread.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncThreads = ref.watch(realtimeChatThreadsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: asyncThreads.when(
        data: (threads) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...threads.map(
              (thread) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ChatTile(
                  thread: thread,
                  onTap: () => ref
                      .read(realtimeChatControllerProvider)
                      .markThreadRead(thread.id),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Quick message to first thread',
                hintText: 'Type and press send',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: threads.isEmpty
                  ? null
                  : () async {
                      await ref
                          .read(realtimeChatControllerProvider)
                          .sendMessage(
                            conversationId: threads.first.id,
                            body: _messageController.text,
                          );
                      _messageController.clear();
                    },
              icon: const Icon(Icons.send_outlined),
              label: const Text('Send'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => context.go(RouteNames.search),
              icon: const Icon(Icons.travel_explore_outlined),
              label: const Text('Find stays and start new chat'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load chats: $error')),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.thread, required this.onTap});

  final ChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(
          thread.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          thread.lastMessage,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_formatTime(thread.lastMessageAt)),
            if (thread.unreadCount > 0) ...[
              const SizedBox(height: 6),
              CircleAvatar(
                radius: 10,
                child: Text(
                  '${thread.unreadCount}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final now = DateTime.now();
    final diff = now.difference(value);
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
}
