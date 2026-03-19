import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../premium/domain/models/subscription_plan.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<void> requestOtp({required String phone}) async {
    final result = await _apiClient.post(
      ApiEndpoints.authOtpRequest,
      data: <String, dynamic>{'phone': phone},
    );

    result.when(success: (_) => null, failure: _throwFailure);
  }

  @override
  Future<AuthUser> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final result = await _apiClient.post(
      ApiEndpoints.authOtpVerify,
      data: <String, dynamic>{'phone': phone, 'code': code},
    );

    return result.when(
      success: (data) {
        final payload = ApiResponseParser.extractMap(data);

        final id = (payload['id'] as String?) ?? '';
        final normalizedPhone = (payload['phone'] as String?) ?? phone;
        final displayName = (payload['displayName'] as String?) ?? 'Tutta User';
        final countryCode = (payload['countryCode'] as String?) ?? 'UZ';
        final accessToken = payload['accessToken'] as String?;
        final subscriptionPlan = _subscriptionFromRaw(
          payload['subscriptionPlan'],
        );

        if (id.isEmpty) {
          throw const AppException('Invalid auth response: missing user id.');
        }

        return AuthUser(
          id: id,
          phone: normalizedPhone,
          displayName: displayName,
          subscriptionPlan: subscriptionPlan,
          countryCode: countryCode,
          accessToken: accessToken,
        );
      },
      failure: _throwFailure,
    );
  }

  @override
  Future<void> signOut() async {
    final result = await _apiClient.post(ApiEndpoints.authSignOut);
    result.when(success: (_) => null, failure: _throwFailure);
  }

  SubscriptionPlan _subscriptionFromRaw(Object? rawValue) {
    if (rawValue is String) {
      final normalized = rawValue.toLowerCase().trim();
      for (final value in SubscriptionPlan.values) {
        if (value.name == normalized) {
          return value;
        }
      }
    }

    return SubscriptionPlan.free;
  }

  Never _throwFailure(Failure failure) {
    throw AppException(
      failure.message,
      code: failure.code,
      statusCode: failure.statusCode,
    );
  }
}
