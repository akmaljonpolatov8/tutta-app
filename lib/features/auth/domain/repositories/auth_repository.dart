import '../models/auth_user.dart';

abstract interface class AuthRepository {
  Future<void> requestOtp({required String phone});

  Future<AuthUser> verifyOtp({required String phone, required String code});

  Future<void> signOut();
}
