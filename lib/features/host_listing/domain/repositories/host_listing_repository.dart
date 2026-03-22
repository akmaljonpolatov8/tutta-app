import '../models/host_listing_draft.dart';

abstract interface class HostListingRepository {
  Future<HostListingDraft> getDraft(String hostUserId);

  Future<HostListingDraft> saveDraft(HostListingDraft draft);

  Future<HostListingDraft> publishDraft(String hostUserId);

  Future<String> uploadPhoto({
    required String hostUserId,
    required String localPath,
  });
}
