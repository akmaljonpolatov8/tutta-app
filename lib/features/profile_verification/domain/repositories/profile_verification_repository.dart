import '../models/profile_verification_status.dart';

abstract interface class ProfileVerificationRepository {
  Future<ProfileVerificationStatus> getStatus(String userId);

  Future<ProfileVerificationStatus> submitVerification({
    required String userId,
    required String fullName,
    required String documentId,
    required String portfolioUrl,
  });
}
