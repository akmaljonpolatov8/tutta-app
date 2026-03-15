import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/tutta_button.dart';

class ListingDetailPage extends StatelessWidget {
  const ListingDetailPage({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.grey200,
                child: const Center(
                  child: Icon(Icons.home, size: 64, color: AppColors.grey400),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_outline),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beautiful Apartment in Tashkent',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.grey400),
                      const SizedBox(width: 4),
                      Text(
                        'Chilonzor, Tashkent',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(24 reviews)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                      const Spacer(),
                      _PropertyFeature(
                          icon: Icons.bed_outlined, label: '2 beds'),
                      const SizedBox(width: 12),
                      _PropertyFeature(
                          icon: Icons.bathtub_outlined, label: '1 bath'),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    AppStrings.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A cozy and modern apartment perfect for short-term stays. '
                    'Located in the heart of Tashkent with easy access to all '
                    'major attractions and transport links.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                          height: 1.6,
                        ),
                  ),
                  const Divider(height: 32),
                  Text(
                    AppStrings.amenities,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _AmenityChip(icon: Icons.wifi, label: 'WiFi'),
                      _AmenityChip(icon: Icons.ac_unit, label: 'AC'),
                      _AmenityChip(
                          icon: Icons.local_parking, label: 'Parking'),
                      _AmenityChip(icon: Icons.kitchen, label: 'Kitchen'),
                      _AmenityChip(icon: Icons.tv, label: 'TV'),
                      _AmenityChip(
                          icon: Icons.local_laundry_service, label: 'Washer'),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(
            top: BorderSide(color: AppColors.grey200),
          ),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$75',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  AppStrings.perNight,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TuttaButton(
                label: AppStrings.bookNow,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyFeature extends StatelessWidget {
  const _PropertyFeature({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey500),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.grey600),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
