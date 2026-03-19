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
}
