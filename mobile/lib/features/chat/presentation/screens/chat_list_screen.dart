import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/chat_provider.dart';
import '../../domain/models/chat_thread.dart';
import '../../domain/models/message.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({
    super.key,
    this.initialListingId,
    this.initialHostId,
  });

  final String? initialListingId;
  final String? initialHostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ChatListView(
      initialListingId: initialListingId,
      initialHostId: initialHostId,
    );
  }
}

class _ChatListView extends ConsumerStatefulWidget {
  const _ChatListView({
    required this.initialListingId,
    required this.initialHostId,
  });

  final String? initialListingId;
  final String? initialHostId;

  @override
  ConsumerState<_ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends ConsumerState<_ChatListView> {
  bool _openingInitial = false;
  bool _initialHandled = false;

  @override
  Widget build(BuildContext context) {
    final threadsAsync = ref.watch(chatThreadsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(RouteNames.home),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Chats'),
      ),
      body: threadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorView(
          message: 'Could not load chats.',
          onRetry: () => ref.invalidate(chatThreadsProvider),
        ),
        data: (threads) {
          _maybeOpenInitialThread(threads);

          if (threads.isEmpty) {
            return const EmptyStateView(
              title: 'No conversations yet',
              subtitle: 'Start chat from listing details to contact hosts.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: threads.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final thread = threads[index];
              return ListTile(
                tileColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEF9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat_bubble_outline),
                ),
                title: Text(
                  'Listing #${thread.listingId}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  thread.lastMessage?.isNotEmpty == true
                      ? thread.lastMessage!
                      : 'Tap to start conversation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: thread.unreadCount > 0
                    ? CircleAvatar(
                        radius: 11,
                        backgroundColor: const Color(0xFF1A5EFF),
                        child: Text(
                          '${thread.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : const Icon(Icons.chevron_right, color: Color(0xFF74809B)),
                onTap: () => _openThread(context, ref, thread),
              );
            },
          );
        },
      ),
    );
  }

  void _maybeOpenInitialThread(List<ChatThread> threads) {
    if (_initialHandled || _openingInitial) {
      return;
    }
    final listingId = widget.initialListingId;
    final hostId = widget.initialHostId;
    if (listingId == null || listingId.isEmpty) {
      _initialHandled = true;
      return;
    }

    _openingInitial = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final existing = threads
            .where((thread) => thread.listingId == listingId)
            .toList(growable: false);
        if (existing.isNotEmpty) {
          _openThread(context, ref, existing.first);
          return;
        }

        if (hostId != null && hostId.isNotEmpty) {
          final created = await ref
              .read(chatActionsProvider)
              .createOrGetThread(listingId: listingId, hostUserId: hostId);
          if (!mounted) {
            return;
          }
          _openThread(context, ref, created);
        }
      } catch (_) {
        // Keep chat list usable even if pre-open fails.
      } finally {
        _initialHandled = true;
        _openingInitial = false;
      }
    });
  }

  void _openThread(BuildContext context, WidgetRef ref, ChatThread thread) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ThreadView(thread: thread),
    );
  }
}

class _ThreadView extends ConsumerStatefulWidget {
  const _ThreadView({required this.thread});

  final ChatThread thread;

  @override
  ConsumerState<_ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends ConsumerState<_ThreadView> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.thread.id));
    final currentUserId =
        ref.watch(authControllerProvider).valueOrNull?.user?.id ?? 'user_demo_1';

    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEF9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_work_outlined),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Listing #${widget.thread.listingId}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => AppErrorView(
                  message: 'Could not load messages.',
                  onRetry: () =>
                      ref.invalidate(chatMessagesProvider(widget.thread.id)),
                ),
                data: (messages) => _buildMessages(messages, currentUserId),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _sending ? null : _send,
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(List<Message> messages, String currentUserId) {
    if (messages.isEmpty) {
      return const EmptyStateView(
        title: 'No messages',
        subtitle: 'Send first message to start conversation.',
      );
    }

    return ListView.separated(
      reverse: true,
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final mine = message.senderUserId == currentUserId;
        return Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? const Color(0xFF1A5EFF) : const Color(0xFFF2F5FB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    style: TextStyle(
                      color: mine ? Colors.white : const Color(0xFF1F2430),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeLabel(message.sentAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: mine
                          ? const Color(0xB3FFFFFF)
                          : const Color(0xFF7A8397),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _timeLabel(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() => _sending = true);
    try {
      await ref
          .read(chatActionsProvider)
          .sendMessage(threadId: widget.thread.id, content: text);
      _controller.clear();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }
}
