import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/models/profile_verification_status.dart';
import '../../domain/repositories/profile_verification_repository.dart';

class ApiProfileVerificationRepository
    implements ProfileVerificationRepository {
  const ApiProfileVerificationRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ProfileVerificationStatus> getStatus(String userId) async {
    final result = await _apiClient.get(
      ApiEndpoints.profileVerification(userId),
    );

    return result.when(
      success: (data) => ProfileVerificationStatus.fromJson(
        ApiResponseParser.extractMap(data),
      ),
      failure: _throwFailure,
    );
  }

  @override
  Future<ProfileVerificationStatus> submitVerification({
    required String userId,
    required String fullName,
    required String documentId,
    required String portfolioUrl,
  }) async {
    final result = await _apiClient.post(
      ApiEndpoints.profileVerification(userId),
      data: <String, dynamic>{
        'fullName': fullName,
        'documentId': documentId,
        'portfolioUrl': portfolioUrl,
      },
    );

    return result.when(
      success: (data) => ProfileVerificationStatus.fromJson(
        ApiResponseParser.extractMap(data),
      ),
      failure: _throwFailure,
    );
  }

  Never _throwFailure(Failure failure) {
    throw AppException(
      failure.message,
      code: failure.code,
      statusCode: failure.statusCode,
    );
  }
}
