import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_role.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../home/application/app_session_controller.dart';
import '../../application/booking_lifecycle_controller.dart';
import '../../application/booking_request_controller.dart';
import '../../domain/models/booking.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  int _reloadToken = 0;
  BookingStatus? _statusFilter;

  String _copy({required String en, required String ru, required String uz}) {
    return _l10n(context, en: en, ru: ru, uz: uz);
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _copy(
              en: 'Updated successfully.',
              ru: 'Успешно обновлено.',
              uz: 'Muvaffaqiyatli yangilandi.',
            ),
          ),
        ),
      );
      setState(() => _reloadToken++);
    } on AppException catch (error) {
      _show(error.message);
    } catch (_) {
      _show(
        _copy(
          en: 'Could not update booking status.',
          ru: 'Не удалось обновить статус брони.',
          uz: 'Bron holatini yangilab bo‘lmadi.',
        ),
      );
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authControllerProvider).valueOrNull?.user?.id;
    final role = ref.watch(appSessionControllerProvider).activeRole;
    final loading = ref.watch(bookingLifecycleControllerProvider).isLoading;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(RouteNames.home),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(_copy(en: 'Bookings', ru: 'Брони', uz: 'Bronlar')),
        ),
        body: Center(
          child: Text(
            _copy(
              en: 'Please sign in to view bookings.',
              ru: 'Войдите в аккаунт, чтобы посмотреть брони.',
              uz: 'Bronlarni ko‘rish uchun tizimga kiring.',
            ),
          ),
        ),
      );
    }

    if (role == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(RouteNames.home),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(_copy(en: 'Bookings', ru: 'Брони', uz: 'Bronlar')),
        ),
        body: Center(
          child: Text(
            _copy(
              en: 'Select renter or host mode first.',
              ru: 'Сначала выберите режим арендатора или хоста.',
              uz: 'Avval mehmon yoki host rejimini tanlang.',
            ),
          ),
        ),
      );
    }

    final future = role == AppRole.host
        ? ref.read(bookingRepositoryProvider).getHostBookings(userId)
        : ref.read(bookingRepositoryProvider).getGuestBookings(userId);

    return FutureBuilder<List<Booking>>(
      key: ValueKey('bookings_$role$_reloadToken'),
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.go(RouteNames.home),
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(
                role == AppRole.host
                    ? _copy(
                        en: 'Host requests',
                        ru: 'Запросы хоста',
                        uz: 'Host so‘rovlari',
                      )
                    : _copy(
                        en: 'My bookings',
                        ru: 'Мои брони',
                        uz: 'Mening bronlarim',
                      ),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final rawItems = snapshot.data ?? const <Booking>[];
        final items = _statusFilter == null
            ? rawItems
            : rawItems
                  .where((booking) => booking.status == _statusFilter)
                  .toList(growable: false);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.go(RouteNames.home),
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(
              role == AppRole.host
                  ? _copy(
                      en: 'Host requests',
                      ru: 'Запросы хоста',
                      uz: 'Host so‘rovlari',
                    )
                  : _copy(
                      en: 'My bookings',
                      ru: 'Мои брони',
                      uz: 'Mening bronlarim',
                    ),
            ),
          ),
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: _BookingScopeBanner(),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text(_copy(en: 'All', ru: 'Все', uz: 'Barchasi')),
                      selected: _statusFilter == null,
                      onSelected: (_) => setState(() => _statusFilter = null),
                    ),
                    const SizedBox(width: 8),
                    ...BookingStatus.values.map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_filterLabel(status)),
                          selected: _statusFilter == status,
                          onSelected: (_) =>
                              setState(() => _statusFilter = status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? _BookingsEmptyState(role: role)
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (role == AppRole.host)
                            _HostSummary(rawItems: rawItems)
                          else
                            _GuestSummary(rawItems: rawItems),
                          const SizedBox(height: 12),
                          ...items.indexed.map((entry) {
                            final index = entry.$1;
                            final booking = entry.$2;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == items.length - 1 ? 0 : 10,
                              ),
                              child: _BookingTile(
                                booking: booking,
                                role: role,
                                loading: loading,
                                onConfirm: () => _runAction(
                                  () => ref
                                      .read(
                                        bookingLifecycleControllerProvider
                                            .notifier,
                                      )
                                      .confirm(booking.id),
                                ),
                                onReject: () => _runAction(
                                  () => ref
                                      .read(
                                        bookingLifecycleControllerProvider
                                            .notifier,
                                      )
                                      .reject(booking.id),
                                ),
                                onCancelByGuest: () => _runAction(
                                  () => ref
                                      .read(
                                        bookingLifecycleControllerProvider
                                            .notifier,
                                      )
                                      .cancelByGuest(booking.id),
                                ),
                                onComplete: () => _runAction(
                                  () => ref
                                      .read(
                                        bookingLifecycleControllerProvider
                                            .notifier,
                                      )
                                      .complete(booking.id),
                                ),
                                onProceedToPayment: () => context.push(
                                  '${RouteNames.bookingPayment}/${booking.id}',
                                ),
                                onLeaveReview: () => context.push(
                                  '${RouteNames.reviewSubmit}/${booking.id}',
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _filterLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pendingHostApproval:
        return _copy(en: 'Pending', ru: 'Ожидание', uz: 'Kutilmoqda');
      case BookingStatus.confirmed:
        return _copy(en: 'Confirmed', ru: 'Подтверждено', uz: 'Tasdiqlangan');
      case BookingStatus.cancelledByGuest:
        return _copy(
          en: 'Guest cancelled',
          ru: 'Отменено гостем',
          uz: 'Mehmon bekor qilgan',
        );
      case BookingStatus.cancelledByHost:
        return _copy(
          en: 'Host cancelled',
          ru: 'Отменено хостом',
          uz: 'Host bekor qilgan',
        );
      case BookingStatus.completed:
        return _copy(en: 'Completed', ru: 'Завершено', uz: 'Yakunlangan');
    }
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({
    required this.booking,
    required this.role,
    required this.loading,
    required this.onConfirm,
    required this.onReject,
    required this.onCancelByGuest,
    required this.onComplete,
    required this.onProceedToPayment,
    required this.onLeaveReview,
  });

  final Booking booking;
  final AppRole role;
  final bool loading;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onCancelByGuest;
  final VoidCallback onComplete;
  final VoidCallback onProceedToPayment;
  final VoidCallback onLeaveReview;

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
                  _l10n(
                    context,
                    en: 'Listing ${booking.listingId}',
                    ru: 'Объявление ${booking.listingId}',
                    uz: 'E’lon ${booking.listingId}',
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
                '${_l10n(context, en: 'Payment', ru: 'Оплата', uz: 'To‘lov')}: ${_paymentLabel(context, booking)}',
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
    if (role == AppRole.host) {
      if (booking.status == BookingStatus.pendingHostApproval) {
        return [
          FilledButton(
            onPressed: loading ? null : onConfirm,
            child: Text(
              _l10n(
                context,
                en: 'Confirm',
                ru: 'Подтвердить',
                uz: 'Tasdiqlash',
              ),
            ),
          ),
          OutlinedButton(
            onPressed: loading ? null : onReject,
            child: Text(
              _l10n(context, en: 'Reject', ru: 'Отклонить', uz: 'Rad etish'),
            ),
          ),
        ];
      }

      if (booking.status == BookingStatus.confirmed) {
        return [
          FilledButton(
            onPressed: loading ? null : onComplete,
            child: Text(
              _l10n(
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

    if (booking.status == BookingStatus.pendingHostApproval) {
      return [
        OutlinedButton(
          onPressed: loading ? null : onCancelByGuest,
          child: Text(
            _l10n(
              context,
              en: 'Cancel request',
              ru: 'Отменить запрос',
              uz: 'So‘rovni bekor qilish',
            ),
          ),
        ),
      ];
    }

    if (booking.status == BookingStatus.confirmed) {
      final actions = <Widget>[];
      if (booking.paymentRequired && !booking.isPaid) {
        actions.add(
          FilledButton(
            onPressed: loading ? null : onProceedToPayment,
            child: Text(
              _l10n(
                context,
                en: 'Proceed to payment',
                ru: 'Перейти к оплате',
                uz: 'To‘lovga o‘tish',
              ),
            ),
          ),
        );
      }
      actions.add(
        OutlinedButton(
          onPressed: loading ? null : onCancelByGuest,
          child: Text(
            _l10n(
              context,
              en: 'Cancel (24h rule)',
              ru: 'Отменить (правило 24ч)',
              uz: 'Bekor qilish (24 soat qoidasi)',
            ),
          ),
        ),
      );
      return actions;
    }

    if (booking.status == BookingStatus.completed && booking.isReviewAllowed) {
      return [
        OutlinedButton(
          onPressed: loading ? null : onLeaveReview,
          child: Text(
            _l10n(
              context,
              en: 'Leave review',
              ru: 'Оставить отзыв',
              uz: 'Sharh qoldirish',
            ),
          ),
        ),
      ];
    }

    return const [];
  }

  String _paymentLabel(BuildContext context, Booking booking) {
    if (!booking.paymentRequired) {
      return _l10n(
        context,
        en: 'Not required',
        ru: 'Не требуется',
        uz: 'Talab qilinmaydi',
      );
    }

    if (booking.paymentStatus == null) {
      return _l10n(
        context,
        en: 'Not paid',
        ru: 'Не оплачено',
        uz: 'To‘lanmagan',
      );
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
      return _l10n(context, en: 'Pending', ru: 'Ожидание', uz: 'Kutilmoqda');
    case BookingStatus.confirmed:
      return _l10n(
        context,
        en: 'Confirmed',
        ru: 'Подтверждено',
        uz: 'Tasdiqlangan',
      );
    case BookingStatus.cancelledByGuest:
      return _l10n(
        context,
        en: 'Guest cancelled',
        ru: 'Отменено гостем',
        uz: 'Mehmon bekor qilgan',
      );
    case BookingStatus.cancelledByHost:
      return _l10n(
        context,
        en: 'Host cancelled',
        ru: 'Отменено хостом',
        uz: 'Host bekor qilgan',
      );
    case BookingStatus.completed:
      return _l10n(
        context,
        en: 'Completed',
        ru: 'Завершено',
        uz: 'Yakunlangan',
      );
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
    final handled = confirmed + completed + rejected;
    final acceptanceRate = handled == 0
        ? 0
        : ((confirmed + completed) * 100 / handled).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricChip(
              label: _l10n(
                context,
                en: 'Pending',
                ru: 'Ожидание',
                uz: 'Kutilmoqda',
              ),
              value: '$pending',
            ),
            _MetricChip(
              label: _l10n(
                context,
                en: 'Confirmed',
                ru: 'Подтверждено',
                uz: 'Tasdiqlangan',
              ),
              value: '$confirmed',
            ),
            _MetricChip(
              label: _l10n(
                context,
                en: 'Completed',
                ru: 'Завершено',
                uz: 'Yakunlangan',
              ),
              value: '$completed',
            ),
            _MetricChip(
              label: _l10n(
                context,
                en: 'Acceptance',
                ru: 'Принято',
                uz: 'Qabul',
              ),
              value: '$acceptanceRate%',
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestSummary extends StatelessWidget {
  const _GuestSummary({required this.rawItems});

  final List<Booking> rawItems;

  @override
  Widget build(BuildContext context) {
    final active = rawItems
        .where(
          (booking) =>
              booking.status == BookingStatus.pendingHostApproval ||
              booking.status == BookingStatus.confirmed,
        )
        .length;
    final completed = rawItems
        .where((booking) => booking.status == BookingStatus.completed)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricChip(
              label: _l10n(context, en: 'Active', ru: 'Активные', uz: 'Faol'),
              value: '$active',
            ),
            _MetricChip(
              label: _l10n(
                context,
                en: 'Completed',
                ru: 'Завершено',
                uz: 'Yakunlangan',
              ),
              value: '$completed',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _BookingScopeBanner extends StatelessWidget {
  const _BookingScopeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n(
              context,
              en: 'Tutta Booking Rules',
              ru: 'Правила бронирования Tutta',
              uz: 'Tutta bron qoidalari',
            ),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            _l10n(
              context,
              en: 'Uzbekistan only. Short-term rental only. Max stay is 30 days.',
              ru: 'Только Узбекистан. Только краткосрочная аренда. Максимум 30 дней.',
              uz: 'Faqat O‘zbekiston. Faqat qisqa muddatli ijara. Maksimal 30 kun.',
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsEmptyState extends StatelessWidget {
  const _BookingsEmptyState({required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy_outlined, size: 34),
            const SizedBox(height: 10),
            Text(
              role == AppRole.host
                  ? _l10n(
                      context,
                      en: 'No incoming booking requests yet.',
                      ru: 'Пока нет входящих запросов на бронь.',
                      uz: 'Hozircha kiruvchi bron so‘rovlari yo‘q.',
                    )
                  : _l10n(
                      context,
                      en: 'No bookings found for this filter.',
                      ru: 'Для этого фильтра брони не найдены.',
                      uz: 'Bu filtr bo‘yicha bronlar topilmadi.',
                    ),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              role == AppRole.host
                  ? _l10n(
                      context,
                      en: 'Once guests request short stays in Uzbekistan, requests will appear here.',
                      ru: 'Когда гости отправят заявки на краткосрочную аренду в Узбекистане, они появятся здесь.',
                      uz: 'Mehmonlar O‘zbekistonda qisqa muddatli bron so‘rov yuborganda, ular shu yerda ko‘rinadi.',
                    )
                  : _l10n(
                      context,
                      en: 'Try changing the filter or discover listings in Uzbekistan to create your first booking.',
                      ru: 'Попробуйте сменить фильтр или выберите жильё в Узбекистане, чтобы создать первую бронь.',
                      uz: 'Filtrni o‘zgartirib ko‘ring yoki O‘zbekistondagi e’lonlarni ochib birinchi bronni yarating.',
                    ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _l10n(
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
