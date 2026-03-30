import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class ListingsSearchPage extends StatefulWidget {
  const ListingsSearchPage({super.key});

  @override
  State<ListingsSearchPage> createState() => _ListingsSearchPageState();
}

class _ListingsSearchPageState extends State<ListingsSearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: false,
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: () {},
            tooltip: AppStrings.filters,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 8,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _SearchResultCard(index: index),
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.listingDetailPath('search-$index')),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.home, size: 48, color: AppColors.grey400),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_outline,
                        size: 18,
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                ],
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
                          'Apartment ${index + 1} in Tashkent',
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            '4.${9 - index % 5}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.grey400),
                      const SizedBox(width: 4),
                      Text(
                        'Chilonzor, Tashkent',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '\$${(index + 1) * 35}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
