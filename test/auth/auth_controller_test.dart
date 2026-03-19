import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutta/core/network/auth_token_provider.dart';
import 'package:tutta/features/auth/application/auth_controller.dart';

void main() {
  group('AuthController', () {
    test('verifyOtp sets authenticated user and auth token', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);

      await controller.requestOtp('+998901112233');
      await controller.verifyOtp('000000');

      final authState = container.read(authControllerProvider).valueOrNull;
      final token = container.read(authTokenProvider);

      expect(authState, isNotNull);
      expect(authState?.isAuthenticated, isTrue);
      expect(authState?.user?.id, 'user_demo_1');
      expect(token, isNotNull);
      expect(token, isNotEmpty);
    });

    test('signOut clears auth token and auth state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);

      await controller.requestOtp('+998901112233');
      await controller.verifyOtp('000000');
      await controller.signOut();

      final authState = container.read(authControllerProvider).valueOrNull;
      final token = container.read(authTokenProvider);

      expect(authState, isNotNull);
      expect(authState?.isAuthenticated, isFalse);
      expect(authState?.user, isNull);
      expect(token, isNull);
    });
  });
}
