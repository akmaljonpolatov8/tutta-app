import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state_view.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: const EmptyStateView(
        title: 'No conversations yet',
        subtitle: 'Start chat from listing details to contact hosts.',
      ),
    );
  }
}
