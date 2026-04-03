import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/booking_lifecycle_controller.dart';
import '../../application/booking_request_controller.dart';
import '../../domain/models/booking.dart';

class HostRequestsScreen extends ConsumerStatefulWidget {
  const HostRequestsScreen({super.key});

  @override
  ConsumerState<HostRequestsScreen> createState() => _HostRequestsScreenState();
}

class _HostRequestsScreenState extends ConsumerState<HostRequestsScreen> {
  BookingStatus? _filter;
  int _reloadToken = 0;

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

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              en: 'Request updated.',
              ru: 'Запрос обновлён.',
              uz: 'So‘rov yangilandi.',
            ),
          ),
        ),
      );
      setState(() => _reloadToken++);
    } on AppException catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostId = ref.watch(authControllerProvider).valueOrNull?.user?.id;
    final loading = ref.watch(bookingLifecycleControllerProvider).isLoading;

    if (hostId == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go(RouteNames.home),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            _t(en: 'Host requests', ru: 'Запросы хоста', uz: 'Host so‘rovlari'),
          ),
        ),
        body: Center(
          child: Text(
            _t(
              en: 'Please sign in again.',
              ru: 'Пожалуйста, войдите снова.',
              uz: 'Iltimos, qayta tizimga kiring.',
            ),
          ),
        ),
      );
    }

    return FutureBuilder<List<Booking>>(
      key: ValueKey('host_requests_$_reloadToken'),
      future: ref.read(bookingRepositoryProvider).getHostBookings(hostId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.go(RouteNames.home),
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(
                _t(
                  en: 'Host requests',
                  ru: 'Запросы хоста',
                  uz: 'Host so‘rovlari',
                ),
              ),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final raw = snapshot.data ?? const <Booking>[];
        final items = _filter == null
            ? raw
            : raw
                  .where((booking) => booking.status == _filter)
                  .toList(growable: false);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.go(RouteNames.home),
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(
              _t(
                en: 'Host requests',
                ru: 'Запросы хоста',
                uz: 'Host so‘rovlari',
              ),
            ),
          ),
          body: Column(
            children: [
              _HostSummary(rawItems: raw),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text(_t(en: 'All', ru: 'Все', uz: 'Barchasi')),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                    const SizedBox(width: 8),
                    ...BookingStatus.values.map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_label(status)),
                          selected: _filter == status,
                          onSelected: (_) => setState(() => _filter = status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _t(
                              en: 'No requests for this filter yet. New Uzbekistan short-stay requests will appear here.',
                              ru: 'Для этого фильтра пока нет запросов. Здесь появятся новые заявки на краткосрочную аренду в Узбекистане.',
                              uz: 'Bu filtr bo‘yicha hozircha so‘rovlar yo‘q. Bu yerda O‘zbekistondagi yangi qisqa muddatli bron so‘rovlari paydo bo‘ladi.',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final booking = items[index];
                          return _HostRequestTile(
                            booking: booking,
                            loading: loading,
                            onConfirm: () => _run(
                              () => ref
                                  .read(
                                    bookingLifecycleControllerProvider.notifier,
                                  )
                                  .confirm(booking.id),
                            ),
                            onReject: () => _run(
                              () => ref
                                  .read(
                                    bookingLifecycleControllerProvider.notifier,
                                  )
                                  .reject(booking.id),
                            ),
                            onComplete: () => _run(
                              () => ref
                                  .read(
                                    bookingLifecycleControllerProvider.notifier,
                                  )
                                  .complete(booking.id),
                            ),
                          );
                        },
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 10),
                        itemCount: items.length,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _label(BookingStatus status) {
    switch (status) {
      case BookingStatus.pendingHostApproval:
        return _t(en: 'Pending', ru: 'Ожидание', uz: 'Kutilmoqda');
      case BookingStatus.confirmed:
        return _t(en: 'Confirmed', ru: 'Подтверждено', uz: 'Tasdiqlangan');
      case BookingStatus.cancelledByGuest:
        return _t(
          en: 'Guest cancelled',
          ru: 'Отменено гостем',
          uz: 'Mehmon bekor qilgan',
        );
      case BookingStatus.cancelledByHost:
        return _t(
          en: 'Host cancelled',
          ru: 'Отменено хостом',
          uz: 'Host bekor qilgan',
        );
      case BookingStatus.completed:
        return _t(en: 'Completed', ru: 'Завершено', uz: 'Yakunlangan');
    }
  }
}

class _HostRequestTile extends StatelessWidget {
  const _HostRequestTile({
    required this.booking,
    required this.loading,
    required this.onConfirm,
    required this.onReject,
    required this.onComplete,
  });

  final Booking booking;
  final bool loading;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final nights = booking.checkOutDate.difference(booking.checkInDate).inDays;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E6F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tr(
                    context,
                    en: 'Booking ${booking.id}',
                    ru: 'Бронь ${booking.id}',
                    uz: 'Bron ${booking.id}',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172146),
                  ),
                ),
              ),
              _StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: Color(0xFF5E6880),
              ),
              const SizedBox(width: 6),
              Text(
                '${_date(booking.checkInDate)} - ${_date(booking.checkOutDate)}',
                style: const TextStyle(color: Color(0xFF3C465E)),
              ),
              const Spacer(),
              Text(
                _nightsLabel(context, nights),
                style: const TextStyle(
                  color: Color(0xFF6C7590),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 16,
                color: Color(0xFF5E6880),
              ),
              const SizedBox(width: 6),
              Text(
                '${_tr(context, en: 'Payment', ru: 'Оплата', uz: 'To‘lov')}: ${_payment(context, booking)}',
                style: const TextStyle(color: Color(0xFF3C465E)),
              ),
              const Spacer(),
              Text(
                _formatUzs(booking.totalPriceUzs),
                style: const TextStyle(
                  color: Color(0xFF0F2F7B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: _actions(context)),
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    if (booking.status == BookingStatus.pendingHostApproval) {
      return [
        FilledButton(
          onPressed: loading ? null : onConfirm,
          child: Text(
            _tr(context, en: 'Confirm', ru: 'Подтвердить', uz: 'Tasdiqlash'),
          ),
        ),
        OutlinedButton(
          onPressed: loading ? null : onReject,
          child: Text(
            _tr(context, en: 'Reject', ru: 'Отклонить', uz: 'Rad etish'),
          ),
        ),
      ];
    }

    if (booking.status == BookingStatus.confirmed) {
      return [
        FilledButton(
          onPressed: loading ? null : onComplete,
          child: Text(
            _tr(
              context,
              en: 'Mark as completed',
              ru: 'Отметить как завершённую',
              uz: 'Yakunlangan deb belgilash',
            ),
          ),
        ),
      ];
    }

    return const [];
  }

  String _payment(BuildContext context, Booking booking) {
    if (!booking.paymentRequired) {
      return _tr(
        context,
        en: 'Not required',
        ru: 'Не требуется',
        uz: 'Talab qilinmaydi',
      );
    }
    if (booking.paymentStatus == null) {
      return _tr(context, en: 'Not paid', ru: 'Не оплачено', uz: 'To‘lanmagan');
    }
    return booking.paymentStatus.toString().split('.').last;
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  String _formatUzs(int value) {
    final raw = value.toString();
    final out = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      out.write(raw[i]);
      final remain = raw.length - i - 1;
      if (remain > 0 && remain % 3 == 0) {
        out.write(' ');
      }
    }
    return '${out.toString()} UZS';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _statusColor(status).withValues(alpha: 0.4)),
      ),
      child: Text(
        _statusLabel(context, status),
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _statusLabel(BuildContext context, BookingStatus status) {
  switch (status) {
    case BookingStatus.pendingHostApproval:
      return _tr(context, en: 'Pending', ru: 'Ожидание', uz: 'Kutilmoqda');
    case BookingStatus.confirmed:
      return _tr(
        context,
        en: 'Confirmed',
        ru: 'Подтверждено',
        uz: 'Tasdiqlangan',
      );
    case BookingStatus.cancelledByGuest:
      return _tr(
        context,
        en: 'Guest cancelled',
        ru: 'Отменено гостем',
        uz: 'Mehmon bekor qilgan',
      );
    case BookingStatus.cancelledByHost:
      return _tr(
        context,
        en: 'Host cancelled',
        ru: 'Отменено хостом',
        uz: 'Host bekor qilgan',
      );
    case BookingStatus.completed:
      return _tr(context, en: 'Completed', ru: 'Завершено', uz: 'Yakunlangan');
  }
}

Color _statusColor(BookingStatus status) {
  switch (status) {
    case BookingStatus.pendingHostApproval:
      return const Color(0xFFAF7A12);
    case BookingStatus.confirmed:
      return const Color(0xFF1A5EFF);
    case BookingStatus.cancelledByGuest:
    case BookingStatus.cancelledByHost:
      return const Color(0xFFD64545);
    case BookingStatus.completed:
      return const Color(0xFF23895B);
  }
}

class _HostSummary extends StatelessWidget {
  const _HostSummary({required this.rawItems});

  final List<Booking> rawItems;

  @override
  Widget build(BuildContext context) {
    final pending = rawItems
        .where((booking) => booking.status == BookingStatus.pendingHostApproval)
        .length;
    final confirmed = rawItems
        .where((booking) => booking.status == BookingStatus.confirmed)
        .length;
    final completed = rawItems
        .where((booking) => booking.status == BookingStatus.completed)
        .length;
    final rejected = rawItems
        .where((booking) => booking.status == BookingStatus.cancelledByHost)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _MetricBadge(
            label: _tr(
              context,
              en: 'Pending',
              ru: 'Ожидание',
              uz: 'Kutilmoqda',
            ),
            value: '$pending',
          ),
          _MetricBadge(
            label: _tr(
              context,
              en: 'Confirmed',
              ru: 'Подтверждено',
              uz: 'Tasdiqlangan',
            ),
            value: '$confirmed',
          ),
          _MetricBadge(
            label: _tr(
              context,
              en: 'Completed',
              ru: 'Завершено',
              uz: 'Yakunlangan',
            ),
            value: '$completed',
          ),
          _MetricBadge(
            label: _tr(
              context,
              en: 'Rejected',
              ru: 'Отклонено',
              uz: 'Rad etilgan',
            ),
            value: '$rejected',
          ),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

String _tr(
  BuildContext context, {
  required String en,
  required String ru,
  required String uz,
}) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'ru':
      return ru;
    case 'uz':
      return uz;
    default:
      return en;
  }
}

String _nightsLabel(BuildContext context, int nights) {
  if (nights < 0) {
    return '';
  }
  switch (Localizations.localeOf(context).languageCode) {
    case 'ru':
      return '$nights ноч.';
    case 'uz':
      return '$nights tun';
    default:
      return '$nights night${nights == 1 ? '' : 's'}';
  }
}
