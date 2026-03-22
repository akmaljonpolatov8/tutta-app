class ApiEndpoints {
  const ApiEndpoints._();

  static const authOtpRequest = '/auth/otp/request';
  static const authOtpVerify = '/auth/otp/verify';
  static const authSignOut = '/auth/sign-out';

  static const bookings = '/bookings';

  static String bookingById(String bookingId) => '$bookings/$bookingId';

  static String guestBookings(String guestUserId) =>
      '$bookings/guest/$guestUserId';

  static String hostBookings(String hostUserId) => '$bookings/host/$hostUserId';

  static String bookingConfirm(String bookingId) =>
      '${bookingById(bookingId)}/confirm';

  static String bookingReject(String bookingId) =>
      '${bookingById(bookingId)}/reject';

  static String bookingCancelByGuest(String bookingId) =>
      '${bookingById(bookingId)}/cancel-by-guest';

  static String bookingComplete(String bookingId) =>
      '${bookingById(bookingId)}/complete';

  static String bookingPaymentStatus(String bookingId) =>
      '${bookingById(bookingId)}/payment-status';

  static const paymentsIntents = '/payments/intents';

  static String paymentIntentById(String paymentIntentId) =>
      '$paymentsIntents/$paymentIntentId';

  static String paymentWebhook(String methodName) =>
      '/payments/webhooks/$methodName';

  static const reviews = '/reviews';

  static String reviewsByListing(String listingId) =>
      '$reviews/listing/$listingId';

  static String chatThreads(String userId) => '/chat/threads/$userId';

  static String chatSendMessage(String conversationId) =>
      '/chat/threads/$conversationId/messages';

  static String notifications(String userId) => '/notifications/$userId';

  static String notificationRead(String userId, String notificationId) =>
      '/notifications/$userId/$notificationId/read';

  static String notificationsReadAll(String userId) =>
      '/notifications/$userId/read-all';

  static String notificationsRegisterDevice(String userId) =>
      '/notifications/$userId/devices';

  static String hostListingDraft(String hostId) =>
      '/host-listings/$hostId/draft';

  static String hostListingPublish(String hostId) =>
      '/host-listings/$hostId/publish';

  static String hostListingUpload(String hostId) =>
      '/host-listings/$hostId/media';

  static String profileVerification(String userId) =>
      '/profile/verification/$userId';
}
