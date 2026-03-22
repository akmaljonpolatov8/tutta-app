import '../../domain/models/profile_verification_status.dart';
import '../../domain/repositories/profile_verification_repository.dart';

class FakeProfileVerificationRepository
    implements ProfileVerificationRepository {
  final Map<String, ProfileVerificationStatus> _items =
      <String, ProfileVerificationStatus>{};

  @override
  Future<ProfileVerificationStatus> getStatus(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return _items[userId] ?? ProfileVerificationStatus.initial(userId);
  }

  @override
  Future<ProfileVerificationStatus> submitVerification({
    required String userId,
    required String fullName,
    required String documentId,
    required String portfolioUrl,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final status = ProfileVerificationStatus(
      userId: userId,
      state: VerificationState.pending,
      note: 'Submitted for review: $fullName ($documentId)',
      updatedAt: DateTime.now(),
    );

    _items[userId] = status;
    return status;
  }
}
