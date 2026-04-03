import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../application/booking_request_controller.dart';
import '../../domain/models/booking.dart';
import '../../../payments/application/payment_controller.dart';
import '../../../payments/domain/models/payment_method.dart';
import '../../../payments/domain/models/payment_status.dart';

class BookingPaymentScreen extends ConsumerStatefulWidget {
  const BookingPaymentScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<BookingPaymentScreen> createState() =>
      _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends ConsumerState<BookingPaymentScreen> {
  String _t({required String en, required String ru, required String uz}) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'ru':
        return ru;
      case 'uz':
        return uz;
      default:
        return en;
    }
  }

  Future<void> _pay({
    required Booking booking,
    required PaymentMethod method,
  }) async {
    if (!booking.paymentRequired) {
      _show(
        _t(
          en: 'Payment is not required for this booking (Free Stay).',
          ru: 'Для этой брони оплата не требуется (Free Stay).',
          uz: 'Ushbu bron uchun to‘lov talab qilinmaydi (Free Stay).',
        ),
      );
      return;
    }

    if (booking.isPaid) {
      _show(
        _t(
          en: 'This booking is already paid.',
          ru: 'Эта бронь уже оплачена.',
          uz: 'Bu bron allaqachon to‘langan.',
        ),
      );
      return;
    }

    try {
      await ref
          .read(paymentControllerProvider.notifier)
          .startPayment(
            bookingId: widget.bookingId,
            amountUzs: booking.totalPriceUzs,
            method: method,
          );

      if (!mounted) {
        return;
      }

      final state = ref.read(paymentControllerProvider);
      final url = state.intent?.checkoutUrl;
      if (url != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                en: 'Checkout created: $url',
                ru: 'Ссылка на оплату создана: $url',
                uz: 'To‘lov havolasi yaratildi: $url',
              ),
            ),
          ),
        );
      }

      await _pollUntilResolved();
    } on AppException catch (error) {
      _show(error.message);
    } catch (_) {
      _show(
        _t(
          en: 'Could not start payment.',
          ru: 'Не удалось начать оплату.',
          uz: 'To‘lovni boshlab bo‘lmadi.',
        ),
      );
    }
  }

  Future<void> _pollUntilResolved() async {
    for (var i = 0; i < 4; i++) {
      final status = await ref
          .read(paymentControllerProvider.notifier)
          .refreshStatus();
      if (!mounted) {
        return;
      }

      if (status == PaymentStatus.succeeded) {
        _show(
          _t(
            en: 'Payment succeeded. Booking is now paid.',
            ru: 'Оплата прошла успешно. Бронь оплачена.',
            uz: 'To‘lov muvaffaqiyatli yakunlandi. Bron to‘landi.',
          ),
        );
        return;
      }
      if (status == PaymentStatus.failed || status == PaymentStatus.cancelled) {
        _show(
          _t(
            en: 'Payment failed or cancelled. Please retry.',
            ru: 'Оплата не прошла или была отменена. Попробуйте снова.',
            uz: 'To‘lov muvaffaqiyatsiz yoki bekor qilingan. Qayta urinib ko‘ring.',
          ),
        );
        return;
      }
    }

    _show(
      _t(
        en: 'Payment is still processing. Check status later.',
        ru: 'Оплата всё ещё обрабатывается. Проверьте статус позже.',
        uz: 'To‘lov hali qayta ishlanmoqda. Holatni keyinroq tekshiring.',
      ),
    );
  }

  void _show(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Booking?>(
      future: ref.read(bookingRepositoryProvider).getById(widget.bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final booking = snapshot.data;
        if (booking == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(RouteNames.bookings),
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(
                _t(
                  en: 'Booking payment',
                  ru: 'Оплата брони',
                  uz: 'Bron to‘lovi',
                ),
              ),
            ),
            body: Center(
              child: Text(
                _t(
                  en: 'Booking not found.',
                  ru: 'Бронь не найдена.',
                  uz: 'Bron topilmadi.',
                ),
              ),
            ),
          );
        }

        final payment = ref.watch(paymentControllerProvider);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.go(RouteNames.bookings),
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(
              _t(en: 'Booking payment', ru: 'Оплата брони', uz: 'Bron to‘lovi'),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                _t(
                  en: 'Pay for booking ${widget.bookingId}',
                  ru: 'Оплата брони ${widget.bookingId}',
                  uz: '${widget.bookingId} broni uchun to‘lov',
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                _t(
                  en: 'Amount: ${booking.totalPriceUzs} UZS',
                  ru: 'Сумма: ${booking.totalPriceUzs} UZS',
                  uz: 'Miqdor: ${booking.totalPriceUzs} UZS',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _t(
                  en: 'Payment required: ${booking.paymentRequired ? 'Yes' : 'No'}',
                  ru: 'Требуется оплата: ${booking.paymentRequired ? 'Да' : 'Нет'}',
                  uz: 'To‘lov kerak: ${booking.paymentRequired ? 'Ha' : 'Yo‘q'}',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _t(
                  en: 'Paid: ${booking.isPaid ? 'Yes' : 'No'}',
                  ru: 'Оплачено: ${booking.isPaid ? 'Да' : 'Нет'}',
                  uz: 'To‘langan: ${booking.isPaid ? 'Ha' : 'Yo‘q'}',
                ),
              ),
              const SizedBox(height: 16),
              if (payment.errorMessage != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(payment.errorMessage!),
                  ),
                ),
              if (payment.intent != null)
                Card(
                  child: ListTile(
                    title: Text(
                      _t(
                        en: 'Intent ${payment.intent!.id}',
                        ru: 'Платёж ${payment.intent!.id}',
                        uz: 'To‘lov ${payment.intent!.id}',
                      ),
                    ),
                    subtitle: Text(
                      '${_t(en: 'Method', ru: 'Метод', uz: 'Usul')}: ${payment.intent!.method.name.toUpperCase()}\n'
                      '${_t(en: 'Status', ru: 'Статус', uz: 'Holat')}: ${_statusText(payment.status ?? PaymentStatus.pending)}',
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed:
                    payment.loading ||
                        booking.isPaid ||
                        !booking.paymentRequired
                    ? null
                    : () => _pay(booking: booking, method: PaymentMethod.click),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                label: Text(
                  _t(
                    en: 'Pay with Click',
                    ru: 'Оплатить через Click',
                    uz: 'Click orqali to‘lash',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed:
                    payment.loading ||
                        booking.isPaid ||
                        !booking.paymentRequired
                    ? null
                    : () => _pay(booking: booking, method: PaymentMethod.payme),
                icon: const Icon(Icons.payment_outlined),
                label: Text(
                  _t(
                    en: 'Pay with Payme',
                    ru: 'Оплатить через Payme',
                    uz: 'Payme orqali to‘lash',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (payment.intent != null)
                TextButton(
                  onPressed: payment.loading
                      ? null
                      : () => ref
                            .read(paymentControllerProvider.notifier)
                            .refreshStatus(),
                  child: Text(
                    _t(
                      en: 'Refresh status',
                      ru: 'Обновить статус',
                      uz: 'Holatni yangilash',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _statusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return _t(en: 'Pending', ru: 'Ожидание', uz: 'Kutilmoqda');
      case PaymentStatus.processing:
        return _t(en: 'Processing', ru: 'Обработка', uz: 'Jarayonda');
      case PaymentStatus.succeeded:
        return _t(en: 'Succeeded', ru: 'Успешно', uz: 'Muvaffaqiyatli');
      case PaymentStatus.failed:
        return _t(en: 'Failed', ru: 'Ошибка', uz: 'Xatolik');
      case PaymentStatus.cancelled:
        return _t(en: 'Cancelled', ru: 'Отменено', uz: 'Bekor qilingan');
    }
  }
}
