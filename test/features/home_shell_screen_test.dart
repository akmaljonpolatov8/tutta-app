import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutta/core/enums/app_role.dart';
import 'package:tutta/features/auth/application/auth_controller.dart';
import 'package:tutta/features/auth/application/auth_state.dart';
import 'package:tutta/features/auth/domain/models/auth_user.dart';
import 'package:tutta/features/auth/domain/repositories/auth_repository.dart';
import 'package:tutta/features/home/application/app_session_controller.dart';
import 'package:tutta/features/home/presentation/screens/home_shell_screen.dart';
import 'package:tutta/features/notifications/application/notifications_controller.dart';
import 'package:tutta/features/premium/domain/models/subscription_plan.dart';
import 'package:tutta/core/errors/app_exception.dart';

void main() {
  testWidgets('shows empty state when role is not selected', (tester) async {
    final sessionController = AppSessionController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSessionControllerProvider.overrideWith((ref) => sessionController),
          unreadNotificationsCountProvider.overrideWithValue(0),
        ],
        child: const MaterialApp(home: HomeShellScreen()),
      ),
    );

    expect(find.text('Role is not selected'), findsOneWidget);
    expect(find.text('Please choose renter or host mode.'), findsOneWidget);
  });

  testWidgets('resets selected tab to first when role changes', (tester) async {
    final sessionController = AppSessionController()..setRole(AppRole.renter);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSessionControllerProvider.overrideWith((ref) => sessionController),
          unreadNotificationsCountProvider.overrideWithValue(0),
        ],
        child: const MaterialApp(home: HomeShellScreen()),
      ),
    );

    expect(find.text('Featured Stays'), findsOneWidget);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Open all messages'), findsOneWidget);

    sessionController.setRole(AppRole.host);
    await tester.pumpAndSettle();

    expect(find.text('Total earnings'), findsOneWidget);
    expect(find.text('Open all messages'), findsNothing);
  });

  testWidgets('switch role clears session role and opens role selector', (
    tester,
  ) async {
    final sessionController = AppSessionController()..setRole(AppRole.renter);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeShellScreen(),
        ),
        GoRoute(
          path: '/role-selector',
          builder: (context, state) =>
              const Scaffold(body: Text('Role Selector Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSessionControllerProvider.overrideWith((ref) => sessionController),
          unreadNotificationsCountProvider.overrideWithValue(0),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.byTooltip('Switch role'));
    await tester.pumpAndSettle();

    expect(find.text('Role Selector Screen'), findsOneWidget);
    expect(sessionController.state.activeRole, isNull);
  });

  testWidgets('prevents duplicate sign out while request is in flight', (
    tester,
  ) async {
    final sessionController = AppSessionController()..setRole(AppRole.renter);
    final authRepository = _CompleterAuthRepository();

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeShellScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) =>
              const Scaffold(body: Text('Auth Screen')),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) =>
              const Scaffold(body: Text('Notifications Screen')),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) =>
              const Scaffold(body: Text('Search Screen')),
        ),
        GoRoute(
          path: '/role-selector',
          builder: (context, state) =>
              const Scaffold(body: Text('Role Selector Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSessionControllerProvider.overrideWith((ref) => sessionController),
          unreadNotificationsCountProvider.overrideWithValue(0),
          authControllerProvider.overrideWith((ref) {
            final controller = AuthController(authRepository, ref);
            controller.state = AsyncValue.data(
              AuthState.initial().copyWith(
                user: const AuthUser(
                  id: 'u-1',
                  phone: '+998901234567',
                  displayName: 'User',
                  subscriptionPlan: SubscriptionPlan.free,
                  countryCode: 'UZ',
                ),
              ),
            );
            return controller;
          }),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    var popScope = tester.widget<PopScope<dynamic>>(find.byType(PopScope));
    expect(popScope.canPop, isTrue);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pump();

    popScope = tester.widget<PopScope<dynamic>>(find.byType(PopScope));
    expect(popScope.canPop, isFalse);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.tap(find.byTooltip('Notifications'));
    await tester.tap(find.byTooltip('Switch role'));
    await tester.tap(find.text('Chat'));
    await tester.tap(find.text('Search stays'), warnIfMissed: false);
    await tester.pump();

    expect(authRepository.signOutCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Featured Stays'), findsOneWidget);
    expect(find.text('Open all messages'), findsNothing);
    expect(find.text('Notifications Screen'), findsNothing);
    expect(find.text('Search Screen'), findsNothing);
    expect(find.text('Role Selector Screen'), findsNothing);

    authRepository.completeSignOut();
    await tester.pumpAndSettle();

    expect(find.text('Auth Screen'), findsOneWidget);
    expect(authRepository.signOutCalls, 1);
    expect(sessionController.state.activeRole, isNull);
  });

  testWidgets('stays on home and shows message when sign out fails', (
    tester,
  ) async {
    final sessionController = AppSessionController()..setRole(AppRole.renter);
    final authRepository = _FailingAuthRepository();

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeShellScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) =>
              const Scaffold(body: Text('Auth Screen')),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) =>
              const Scaffold(body: Text('Notifications Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSessionControllerProvider.overrideWith((ref) => sessionController),
          unreadNotificationsCountProvider.overrideWithValue(0),
          authControllerProvider.overrideWith((ref) {
            final controller = AuthController(authRepository, ref);
            controller.state = AsyncValue.data(
              AuthState.initial().copyWith(user: _testUser('u-1')),
            );
            return controller;
          }),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();

    final popScope = tester.widget<PopScope<dynamic>>(find.byType(PopScope));
    expect(popScope.canPop, isTrue);
    expect(find.byTooltip('Sign out'), findsOneWidget);
    expect(find.text('Unable to sign out right now.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(authRepository.signOutCalls, 1);

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications Screen'), findsOneWidget);
  });
}

class _CompleterAuthRepository implements AuthRepository {
  final Completer<void> _completer = Completer<void>();
  int signOutCalls = 0;

  void completeSignOut() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  @override
  Future<void> requestOtp({required String phone}) async {}

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    await _completer.future;
  }

  @override
  Future<AuthUser> verifyOtp({required String phone, required String code}) {
    throw UnimplementedError();
  }
}

class _FailingAuthRepository implements AuthRepository {
  int signOutCalls = 0;

  @override
  Future<void> requestOtp({required String phone}) async {}

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    throw const AppException('Unable to sign out right now.');
  }

  @override
  Future<AuthUser> verifyOtp({required String phone, required String code}) {
    throw UnimplementedError();
  }
}

AuthUser _testUser(String id) {
  return AuthUser(
    id: id,
    phone: '+998901234567',
    displayName: 'User $id',
    subscriptionPlan: SubscriptionPlan.free,
    countryCode: 'UZ',
  );
}
