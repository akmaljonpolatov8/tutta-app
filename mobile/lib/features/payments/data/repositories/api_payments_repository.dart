import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/models/payment_intent.dart';
import '../../domain/models/payment_method.dart';
import '../../domain/models/payment_status.dart';
import '../../domain/models/payment_webhook_event.dart';
import '../../domain/repositories/payments_repository.dart';

class ApiPaymentsRepository implements PaymentsRepository {
  const ApiPaymentsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaymentIntent> createBookingPaymentIntent({
    required String bookingId,
    required int amountUzs,
    required PaymentMethod method,
  }) async {
    final result = await _apiClient.post(
      ApiEndpoints.paymentsIntents,
      data: <String, dynamic>{
        'bookingId': bookingId,
        'amountUzs': amountUzs,
        'method': method.name,
      },
    );

    return result.when(
      success: (data) {
        final payload = ApiResponseParser.extractMap(data);
        return PaymentIntent.fromJson(payload);
      },
      failure: _throwFailure,
    );
  }

  @override
  Future<PaymentStatus> getPaymentStatus(String paymentIntentId) async {
    final result = await _apiClient.get(
      ApiEndpoints.paymentIntentById(paymentIntentId),
    );

    return result.when(
      success: (data) {
        final payload = ApiResponseParser.extractMap(data);
        final rawStatus = payload['status'];
        return _statusFromServer(rawStatus);
      },
      failure: _throwFailure,
    );
  }

  @override
  Future<PaymentStatus> processWebhook(PaymentWebhookEvent event) async {
    final signature = _buildDevSignature(event);
    final idempotencyKey =
        '${event.externalTransactionId}-${event.status.name}-${event.method.name}';

    final result = await _apiClient.post(
      ApiEndpoints.paymentWebhook(event.method.name),
      data: <String, dynamic>{
        'transactionId': event.externalTransactionId,
        'status': event.status.name,
      },
      headers: <String, String>{
        'x-tutta-signature': signature,
        'x-idempotency-key': idempotencyKey,
      },
    );

    return result.when(
      success: (data) {
        final payload = ApiResponseParser.extractMap(data);
        final rawStatus = payload['status'];
        return _statusFromServer(rawStatus);
      },
      failure: _throwFailure,
    );
  }

  PaymentStatus _statusFromServer(Object? rawStatus) {
    if (rawStatus is String) {
      final normalized = rawStatus.toLowerCase().trim();
      for (final status in PaymentStatus.values) {
        if (status.name == normalized) {
          return status;
        }
      }
    }

    throw const AppException('Unknown payment status from server.');
  }

  Never _throwFailure(Failure failure) {
    throw AppException(
      failure.message,
      code: failure.code,
      statusCode: failure.statusCode,
    );
  }

  String _buildDevSignature(PaymentWebhookEvent event) {
    return 'dev-signature:${event.method.name}:${event.externalTransactionId}:${event.status.name}';
  }
}
