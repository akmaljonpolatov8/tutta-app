import '../../domain/models/host_listing_draft.dart';
import '../../domain/repositories/host_listing_repository.dart';

class FakeHostListingRepository implements HostListingRepository {
  final Map<String, HostListingDraft> _drafts = <String, HostListingDraft>{};

  @override
  Future<HostListingDraft> getDraft(String hostUserId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _drafts[hostUserId] ?? HostListingDraft.empty(hostUserId);
  }

  @override
  Future<HostListingDraft> saveDraft(HostListingDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final saved = draft.copyWith(updatedAt: DateTime.now(), published: false);
    _drafts[draft.hostUserId] = saved;
    return saved;
  }

  @override
  Future<HostListingDraft> publishDraft(String hostUserId) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final current = _drafts[hostUserId] ?? HostListingDraft.empty(hostUserId);
    final published = current.copyWith(
      published: true,
      updatedAt: DateTime.now(),
    );
    _drafts[hostUserId] = published;
    return published;
  }

  @override
  Future<String> uploadPhoto({
    required String hostUserId,
    required String localPath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (localPath.startsWith('http://') || localPath.startsWith('https://')) {
      return localPath;
    }

    final stamp = DateTime.now().millisecondsSinceEpoch;
    return 'https://picsum.photos/seed/${hostUserId}_$stamp/1200/800';
  }
}
