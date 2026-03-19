import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/runtime_flags.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/auth_token_provider.dart';
import '../data/repositories/api_auth_repository.dart';
import '../data/repositories/fake_auth_repository.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (!RuntimeFlags.useFakeAuth) {
    return ApiAuthRepository(ref.watch(apiClientProvider));
  }

  return FakeAuthRepository();
});

class AuthController extends StateNotifier<AsyncValue<AuthState>> {
  AuthController(this._authRepository, this._read)
    : super(const AsyncValue.data(AuthState.initial()));

  final AuthRepository _authRepository;
  final Ref _read;

  Future<void> requestOtp(String phone) async {
    final current = state.valueOrNull ?? const AuthState.initial();
    state = const AsyncValue.loading();

    try {
      await _authRepository.requestOtp(phone: phone);
      state = AsyncValue.data(current.copyWith(phoneForOtp: phone));
    } on AppException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } catch (error, stackTrace) {
      state = AsyncValue.error(AppException(error.toString()), stackTrace);
    }
  }

  Future<void> verifyOtp(String code) async {
    final current = state.valueOrNull ?? const AuthState.initial();
    final phone = current.phoneForOtp;

    if (phone == null || phone.isEmpty) {
      state = AsyncValue.error(
        const AppException('Phone number is missing. Request OTP first.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      final user = await _authRepository.verifyOtp(phone: phone, code: code);
      _read.read(authTokenProvider.notifier).state = user.accessToken;
      state = AsyncValue.data(current.copyWith(user: user));
    } on AppException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } catch (error, stackTrace) {
      state = AsyncValue.error(AppException(error.toString()), stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.signOut();
      _read.read(authTokenProvider.notifier).state = null;
      state = const AsyncValue.data(AuthState.initial());
    } on AppException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } catch (error, stackTrace) {
      state = AsyncValue.error(AppException(error.toString()), stackTrace);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthState>>((ref) {
      return AuthController(ref.watch(authRepositoryProvider), ref);
    });
