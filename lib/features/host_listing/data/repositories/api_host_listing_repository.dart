import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/models/host_listing_draft.dart';
import '../../domain/repositories/host_listing_repository.dart';

class ApiHostListingRepository implements HostListingRepository {
  const ApiHostListingRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<HostListingDraft> getDraft(String hostUserId) async {
    final result = await _apiClient.get(
      ApiEndpoints.hostListingDraft(hostUserId),
    );

    return result.when(
      success: (data) =>
          HostListingDraft.fromJson(ApiResponseParser.extractMap(data)),
      failure: _throwFailure,
    );
  }

  @override
  Future<HostListingDraft> saveDraft(HostListingDraft draft) async {
    final result = await _apiClient.post(
      ApiEndpoints.hostListingDraft(draft.hostUserId),
      data: draft.toJson(),
    );

    return result.when(
      success: (data) =>
          HostListingDraft.fromJson(ApiResponseParser.extractMap(data)),
      failure: _throwFailure,
    );
  }

  @override
  Future<HostListingDraft> publishDraft(String hostUserId) async {
    final result = await _apiClient.post(
      ApiEndpoints.hostListingPublish(hostUserId),
    );

    return result.when(
      success: (data) =>
          HostListingDraft.fromJson(ApiResponseParser.extractMap(data)),
      failure: _throwFailure,
    );
  }

  @override
  Future<String> uploadPhoto({
    required String hostUserId,
    required String localPath,
  }) async {
    final result = await _apiClient.post(
      ApiEndpoints.hostListingUpload(hostUserId),
      data: <String, dynamic>{'localPath': localPath},
    );

    return result.when(
      success: (data) {
        final payload = ApiResponseParser.extractMap(data);
        final url = payload['url'] as String?;
        if (url == null || url.isEmpty) {
          throw const AppException(
            'Media upload response does not contain url.',
          );
        }
        return url;
      },
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
