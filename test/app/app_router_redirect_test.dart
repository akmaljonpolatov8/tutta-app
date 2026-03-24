import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutta/app/router/app_router.dart';
import 'package:tutta/features/auth/application/auth_controller.dart';
import 'package:tutta/features/auth/application/auth_state.dart';
import 'package:tutta/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:tutta/features/home/application/app_session_controller.dart';

void main() {
  testWidgets('redirects unauthenticated user to onboarding without loop', (
    tester,
  ) async {
    final sessionController = AppSessionController();

    final container = ProviderContainer(
      overrides: [
        appSessionControllerProvider.overrideWith((ref) => sessionController),
        authControllerProvider.overrideWith((ref) {
          final controller = AuthController(FakeAuthRepository(), ref);
          controller.state = const AsyncValue.data(AuthState.initial());
          return controller;
        }),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Step 1 / 3'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
  });
}
