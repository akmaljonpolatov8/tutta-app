import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/runtime_flags.dart';
import '../../../core/network/api_client.dart';
import '../../auth/application/auth_controller.dart';
import '../data/repositories/api_profile_verification_repository.dart';
import '../data/repositories/fake_profile_verification_repository.dart';
import '../domain/models/profile_verification_status.dart';
import '../domain/repositories/profile_verification_repository.dart';

final profileVerificationRepositoryProvider =
    Provider<ProfileVerificationRepository>((ref) {
      if (!RuntimeFlags.useFakeProfileVerification) {
        return ApiProfileVerificationRepository(ref.watch(apiClientProvider));
      }
      return FakeProfileVerificationRepository();
    });

class ProfileVerificationController
    extends StateNotifier<AsyncValue<ProfileVerificationStatus?>> {
  ProfileVerificationController(this._ref, this._repository)
    : super(const AsyncValue.data(null));

  final Ref _ref;
  final ProfileVerificationRepository _repository;

  String? get _userId =>
      _ref.read(authControllerProvider).valueOrNull?.user?.id;

  Future<void> load() async {
    final userId = _userId;
    if (userId == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.getStatus(userId);
    });
  }

  Future<void> submit({
    required String fullName,
    required String documentId,
    required String portfolioUrl,
  }) async {
    final userId = _userId;
    if (userId == null) {
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.submitVerification(
        userId: userId,
        fullName: fullName,
        documentId: documentId,
        portfolioUrl: portfolioUrl,
      );
    });
  }
}

final profileVerificationControllerProvider =
    StateNotifierProvider.autoDispose<
      ProfileVerificationController,
      AsyncValue<ProfileVerificationStatus?>
    >((ref) {
      return ProfileVerificationController(
        ref,
        ref.watch(profileVerificationRepositoryProvider),
      );
    });
