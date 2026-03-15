import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.myBookings),
          bottom: const TabBar(
            tabs: [
              Tab(text: AppStrings.upcomingBookings),
              Tab(text: AppStrings.pastBookings),
              Tab(text: AppStrings.cancelledBookings),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BookingsTab(status: 'upcoming'),
            _BookingsTab(status: 'past'),
            _BookingsTab(status: 'cancelled'),
          ],
        ),
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel_outlined,
                size: 56, color: AppColors.grey400),
            const SizedBox(height: 12),
            Text(
              'No cancelled bookings',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: status == 'upcoming' ? 2 : 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _BookingCard(
        index: index,
        status: status,
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.index, required this.status});
  final int index;
  final String status;

  Color get _statusColor {
    switch (status) {
      case 'upcoming':
        return AppColors.success;
      case 'past':
        return AppColors.grey500;
      default:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (status) {
      case 'upcoming':
        return AppStrings.bookingConfirmed;
      case 'past':
        return 'Completed';
      default:
        return AppStrings.bookingCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 140,
              color: AppColors.grey200,
              child: const Center(
                child: Icon(Icons.home, size: 40, color: AppColors.grey400),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Apartment ${index + 1}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _statusLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.grey400),
                    const SizedBox(width: 4),
                    Text(
                      'Mar ${15 + index} – Mar ${18 + index}, 2026',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${(index + 1) * 75} total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
