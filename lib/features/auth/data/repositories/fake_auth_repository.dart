import '../../../../core/errors/app_exception.dart';
import '../../../premium/domain/models/subscription_plan.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  static const _demoOtpCode = '000000';

  @override
  Future<void> requestOtp({required String phone}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!phone.startsWith('+998')) {
      throw const AppException('Only Uzbekistan phone numbers are supported.');
    }
  }

  @override
  Future<AuthUser> verifyOtp({
    required String phone,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (code != _demoOtpCode) {
      throw const AppException('Invalid OTP. Use 000000 for local demo.');
    }

    return AuthUser(
      id: 'user_demo_1',
      phone: phone,
      displayName: 'Tutta User',
      subscriptionPlan: SubscriptionPlan.free,
      countryCode: 'UZ',
      accessToken: 'demo_access_token_user_demo_1',
    );
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
