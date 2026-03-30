class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main shell (bottom nav)
  static const String home = '/home';
  static const String search = '/search';
  static const String wishlist = '/wishlist';
  static const String bookings = '/bookings';
  static const String profile = '/profile';

  // Listings
  static const String listingDetail = '/listings/:id';
  static const String listingCreate = '/listings/create';
  static const String listingEdit = '/listings/:id/edit';

  // Booking
  static const String bookingCreate = '/bookings/create';
  static const String bookingDetail = '/bookings/:id';

  // Profile
  static const String editProfile = '/profile/edit';
  static const String settings = '/profile/settings';
  static const String notifications = '/profile/notifications';

  // Helpers
  static String listingDetailPath(String id) => '/listings/$id';
  static String bookingDetailPath(String id) => '/bookings/$id';
  static String listingEditPath(String id) => '/listings/$id/edit';
}
