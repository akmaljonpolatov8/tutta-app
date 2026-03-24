import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/message.dart';

final chatMessagesProvider = StateProvider<AsyncValue<List<Message>>>((ref) {
  return const AsyncValue.data(<Message>[]);
});
