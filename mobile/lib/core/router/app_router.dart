import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/booking/presentation/pages/bookings_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/listings/presentation/pages/listing_detail_page.dart';
import '../../features/listings/presentation/pages/listings_search_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/main_shell.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.search,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ListingsSearchPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.bookings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookingsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/listings/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ListingDetailPage(listingId: id);
        },
      ),
    ],
  );
}
