import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../payments/domain/models/payment_status.dart';
import '../../domain/models/booking.dart';
import '../../domain/repositories/booking_repository.dart';

class ApiBookingRepository implements BookingRepository {
  const ApiBookingRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Booking?> getById(String bookingId) async {
    final result = await _apiClient.get(ApiEndpoints.bookingById(bookingId));

    return result.when(
      success: (data) {
        final payload = ApiResponseParser.extractMap(data);
        if (payload.isEmpty) {
          return null;
        }
        return Booking.fromJson(payload);
      },
      failure: (failure) {
        if (failure.statusCode == 404) {
          return null;
        }
        _throwFailure(failure);
      },
    );
  }

  @override
  Future<Booking> createBookingRequest({
    required String listingId,
    required String guestUserId,
    required String hostUserId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required int totalPriceUzs,
  }) async {
    final result = await _apiClient.post(
      ApiEndpoints.bookings,
      data: <String, dynamic>{
        'listingId': listingId,
        'guestUserId': guestUserId,
        'hostUserId': hostUserId,
        'checkInDate': checkIn.toIso8601String(),
        'checkOutDate': checkOut.toIso8601String(),
        'guestsCount': guests,
        'totalPriceUzs': totalPriceUzs,
      },
    );

    return result.when(
      success: (data) => Booking.fromJson(ApiResponseParser.extractMap(data)),
      failure: _throwFailure,
    );
  }

  @override
  Future<List<Booking>> getGuestBookings(String guestUserId) async {
    final result = await _apiClient.get(
      ApiEndpoints.guestBookings(guestUserId),
    );

    return result.when(
      success: (data) => ApiResponseParser.extractList(
        data,
      ).map((item) => Booking.fromJson(item)).toList(growable: false),
      failure: _throwFailure,
    );
  }

  @override
  Future<List<Booking>> getHostBookings(String hostUserId) async {
    final result = await _apiClient.get(ApiEndpoints.hostBookings(hostUserId));

    return result.when(
      success: (data) => ApiResponseParser.extractList(
        data,
      ).map((item) => Booking.fromJson(item)).toList(growable: false),
      failure: _throwFailure,
    );
  }

  @override
  Future<Booking> confirmBooking({
    required String bookingId,
    required String hostUserId,
  }) {
    return _runAction(
      bookingId: bookingId,
      pathSuffix: 'confirm',
      actorUserId: hostUserId,
      actorField: 'hostUserId',
    );
  }

  @override
  Future<Booking> rejectBooking({
    required String bookingId,
    required String hostUserId,
  }) {
    return _runAction(
      bookingId: bookingId,
      pathSuffix: 'reject',
      actorUserId: hostUserId,
      actorField: 'hostUserId',
    );
  }

  @override
  Future<Booking> cancelByGuest({
    required String bookingId,
    required String guestUserId,
  }) {
    return _runAction(
      bookingId: bookingId,
      pathSuffix: 'cancel-by-guest',
      actorUserId: guestUserId,
      actorField: 'guestUserId',
    );
  }

  @override
  Future<Booking> markCompleted({
    required String bookingId,
    required String hostUserId,
  }) {
    return _runAction(
      bookingId: bookingId,
      pathSuffix: 'complete',
      actorUserId: hostUserId,
      actorField: 'hostUserId',
    );
  }

  @override
  Future<Booking> setPaymentStatus({
    required String bookingId,
    required String guestUserId,
    required PaymentStatus paymentStatus,
  }) async {
    final result = await _apiClient.post(
      ApiEndpoints.bookingPaymentStatus(bookingId),
      data: <String, dynamic>{
        'guestUserId': guestUserId,
        'paymentStatus': paymentStatus.name,
      },
    );

    return result.when(
      success: (data) => Booking.fromJson(ApiResponseParser.extractMap(data)),
      failure: _throwFailure,
    );
  }

  Future<Booking> _runAction({
    required String bookingId,
    required String pathSuffix,
    required String actorUserId,
    required String actorField,
  }) async {
    final result = await _apiClient.post(
      '${ApiEndpoints.bookingById(bookingId)}/$pathSuffix',
      data: <String, dynamic>{actorField: actorUserId},
    );

    return result.when(
      success: (data) => Booking.fromJson(ApiResponseParser.extractMap(data)),
      failure: _throwFailure,
    );
  }

  Never _throwFailure(Failure failure) {
    throw AppException(
      failure.message,
      code: failure.code,
      statusCode: failure.statusCode,
    );
  }
}
