import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/runtime_flags.dart';
import '../../../core/network/api_client.dart';
import '../../auth/application/auth_controller.dart';
import '../data/repositories/api_host_listing_repository.dart';
import '../data/repositories/fake_host_listing_repository.dart';
import '../domain/models/host_listing_draft.dart';
import '../domain/repositories/host_listing_repository.dart';

final hostListingRepositoryProvider = Provider<HostListingRepository>((ref) {
  if (!RuntimeFlags.useFakeHostListing) {
    return ApiHostListingRepository(ref.watch(apiClientProvider));
  }
  return FakeHostListingRepository();
});

class HostListingController
    extends StateNotifier<AsyncValue<HostListingDraft?>> {
  HostListingController(this._ref, this._repository)
    : super(const AsyncValue.data(null));

  final Ref _ref;
  final HostListingRepository _repository;

  String? get _hostUserId =>
      _ref.read(authControllerProvider).valueOrNull?.user?.id;

  Future<void> loadDraft() async {
    final hostId = _hostUserId;
    if (hostId == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.getDraft(hostId);
    });
  }

  Future<void> saveDraft({
    required String title,
    required String city,
    required String district,
    required int pricePerNightUsd,
    required int guests,
    required int bedrooms,
    required List<String> amenities,
    required List<String> imageUrls,
  }) async {
    final hostId = _hostUserId;
    if (hostId == null) {
      return;
    }

    final current = state.valueOrNull ?? HostListingDraft.empty(hostId);
    final draft = current.copyWith(
      title: title,
      city: city,
      district: district,
      pricePerNightUsd: pricePerNightUsd,
      guests: guests,
      bedrooms: bedrooms,
      amenities: amenities,
      imageUrls: imageUrls,
      updatedAt: DateTime.now(),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.saveDraft(draft);
    });
  }

  Future<String?> uploadPhoto(String localPath) async {
    final hostId = _hostUserId;
    if (hostId == null) {
      return null;
    }

    return _repository.uploadPhoto(hostUserId: hostId, localPath: localPath);
  }

  Future<void> publishDraft() async {
    final hostId = _hostUserId;
    if (hostId == null) {
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.publishDraft(hostId);
    });
  }
}

final hostListingControllerProvider =
    StateNotifierProvider.autoDispose<
      HostListingController,
      AsyncValue<HostListingDraft?>
    >((ref) {
      return HostListingController(
        ref,
        ref.watch(hostListingRepositoryProvider),
      );
    });
