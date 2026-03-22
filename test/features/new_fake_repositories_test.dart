import 'package:flutter_test/flutter_test.dart';
import 'package:tutta/features/chat/data/repositories/fake_chat_repository.dart';
import 'package:tutta/features/host_listing/data/repositories/fake_host_listing_repository.dart';
import 'package:tutta/features/host_listing/domain/models/host_listing_draft.dart';
import 'package:tutta/features/notifications/data/repositories/fake_notifications_repository.dart';
import 'package:tutta/features/notifications/domain/models/push_notification_item.dart';
import 'package:tutta/features/profile_verification/data/repositories/fake_profile_verification_repository.dart';

void main() {
  test('fake host listing upload and publish flow', () async {
    final repository = FakeHostListingRepository();
    final uploaded = await repository.uploadPhoto(
      hostUserId: 'host-1',
      localPath: 'c:/tmp/pic.jpg',
    );

    final saved = await repository.saveDraft(
      HostListingDraft.empty(
        'host-1',
      ).copyWith(title: 'Test listing', imageUrls: <String>[uploaded]),
    );
    final published = await repository.publishDraft('host-1');

    expect(saved.imageUrls, isNotEmpty);
    expect(published.published, isTrue);
  });

  test('fake profile verification returns pending after submit', () async {
    final repository = FakeProfileVerificationRepository();

    final status = await repository.submitVerification(
      userId: 'u-1',
      fullName: 'User',
      documentId: 'DOC1',
      portfolioUrl: 'https://portfolio',
    );

    expect(status.state.name, 'pending');
  });

  test('fake chat repository emits updates and supports send/read', () async {
    final repository = FakeChatRepository();

    final first = await repository.watchThreads('u-1').first;

    expect(first, isNotEmpty);

    await repository.sendMessage(
      conversationId: first.first.id,
      senderUserId: 'u-1',
      body: 'Hello there',
    );

    await repository.markThreadRead(userId: 'u-1', threadId: first.first.id);
    final updated = await repository.watchThreads('u-1').first;
    expect(
      updated.first.unreadCount,
      lessThanOrEqualTo(first.first.unreadCount),
    );
  });

  test('fake notifications push and mark all read', () async {
    final repository = FakeNotificationsRepository();

    await repository.watchNotifications('u-1').first;
    await repository.registerDeviceToken(userId: 'u-1', fcmToken: 'tok_123');
    await repository.pushLocal(
      PushNotificationItem(
        id: 'n_local',
        userId: 'u-1',
        title: 'Hi',
        body: 'Body',
        type: PushNotificationType.chat,
        deepLink: '/chat',
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );

    final items = await repository.watchNotifications('u-1').first;
    expect(items.any((item) => item.id == 'n_local'), isTrue);

    await repository.markAllAsRead('u-1');
    final readItems = await repository.watchNotifications('u-1').first;
    expect(readItems.every((item) => item.isRead), isTrue);
  });
}
