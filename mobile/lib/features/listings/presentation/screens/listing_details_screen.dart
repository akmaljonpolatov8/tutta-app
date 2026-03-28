import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../reviews/application/review_submit_controller.dart';
import '../../application/search_controller.dart';
import '../../domain/models/listing.dart';
import '../../../wishlist/application/favorites_controller.dart';

class ListingDetailsScreen extends ConsumerWidget {
  const ListingDetailsScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Listing?>(
      future: ref.read(listingsRepositoryProvider).getById(listingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final listing = snapshot.data;
        if (listing == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(RouteNames.search),
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Listing'),
            ),
            body: const Center(child: Text('Listing not found.')),
          );
        }

        final hasPremium =
            ref.watch(authControllerProvider).valueOrNull?.user?.isPremium ??
            false;
        final currentUserId =
            ref.watch(authControllerProvider).valueOrNull?.user?.id;
        final isOwner = currentUserId != null && currentUserId == listing.hostId;

        final freeStayLocked =
            listing.type == ListingType.freeStay && !hasPremium;
        final isFavorite = ref.watch(
          favoritesIdsProvider.select((ids) => ids.contains(listing.id)),
        );

        final imageUrl = listing.imageUrls.isEmpty
            ? null
            : listing.imageUrls.first;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F5F7),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                leading: IconButton(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(RouteNames.search),
                  icon: const Icon(Icons.arrow_back),
                ),
                actions: [
                  if (isOwner)
                    IconButton(
                      onPressed: () => context.push(
                        '${RouteNames.listingAvailability}/${listing.id}',
                      ),
                      icon: const Icon(Icons.calendar_month_outlined),
                    ),
                  if (isOwner)
                    IconButton(
                      onPressed: () =>
                          context.push('${RouteNames.editListing}/${listing.id}'),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  IconButton(
                    onPressed: () => ref
                        .read(favoritesIdsProvider.notifier)
                        .toggle(listing.id),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          isFavorite ? const Color(0xFFD64545) : Colors.white,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _ListingHero(
                    imageUrl: imageUrl,
                    city: listing.city,
                    district: listing.district,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                            listing.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          )
                          .animate()
                          .fadeIn(duration: 220.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Color(0xFF6D7280),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${listing.city}, ${listing.district}',
                            style: const TextStyle(
                              color: Color(0xFF6D7280),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ).animate(delay: 60.ms).fadeIn(duration: 220.ms),
                      const SizedBox(height: 14),
                      _InfoPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (listing.imageUrls.length > 1) ...[
                                  SizedBox(
                                    height: 84,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: listing.imageUrls.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final url = listing.imageUrls[index];
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.network(
                                            url,
                                            width: 110,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                Container(
                                                  width: 110,
                                                  color: const Color(
                                                    0xFF263352,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                Text(
                                  listing.description ?? 'No description yet.',
                                  style: const TextStyle(
                                    color: Color(0xFF1F2430),
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _SoftTag(
                                      label: 'Max guests: ${listing.maxGuests}',
                                    ),
                                    _SoftTag(
                                      label: 'Min days: ${listing.minDays}',
                                    ),
                                    _SoftTag(
                                      label: 'Max days: ${listing.maxDays}',
                                    ),
                                    _SoftTag(
                                      label: listing.nightlyPriceUzs == null
                                          ? 'Free stay / exchange'
                                          : '${listing.nightlyPriceUzs} UZS / night',
                                      isAccent: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Reviews',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2430),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _ReviewsBlock(listingId: listing.id),
                              ],
                            ),
                          )
                          .animate(delay: 110.ms)
                          .fadeIn(duration: 240.ms)
                          .slideY(begin: 0.06, end: 0),
                      if (freeStayLocked) ...[
                        const SizedBox(height: 14),
                        _InfoPanel(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium_outlined,
                                    color: Color(0xFFC8A84B),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Premium required',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1F2430),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Free Stay bookings are available only for Premium users.',
                                          style: TextStyle(
                                            color: Color(0xFF6D7280),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton(
                                          onPressed: () => context.push(
                                            RouteNames.premiumPaywall,
                                          ),
                                          child: const Text('Upgrade'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate(delay: 170.ms)
                            .fadeIn(duration: 240.ms)
                            .slideY(begin: 0.06, end: 0),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE1E3E8)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A0C1833),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => isOwner
                          ? context.push('${RouteNames.editListing}/${listing.id}')
                          : context.push(
                                '${RouteNames.chatList}?listingId=${listing.id}&hostId=${listing.hostId}',
                              ),
                      icon: Icon(
                        isOwner ? Icons.edit_outlined : Icons.chat_bubble_outline,
                      ),
                      label: Text(isOwner ? 'Edit listing' : 'Chat'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (freeStayLocked) {
                          context.push(RouteNames.premiumPaywall);
                          return;
                        }
                        if (isOwner) {
                          context.push(
                            '${RouteNames.listingAvailability}/${listing.id}',
                          );
                          return;
                        }
                        context.push(
                          '${RouteNames.bookingRequest}/${listing.id}',
                        );
                      },
                      icon: const Icon(Icons.event_available_outlined),
                      label: Text(
                        freeStayLocked
                            ? 'Premium required'
                            : (isOwner ? 'Manage calendar' : 'Request booking'),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.3, end: 0),
          ),
        );
      },
    );
  }
}

class _ListingHero extends StatelessWidget {
  const _ListingHero({
    required this.imageUrl,
    required this.city,
    required this.district,
  });

  final String? imageUrl;
  final String city;
  final String district;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _fallback(),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x26000000), Color(0x8A000000)],
              ),
            ),
          ),
        ],
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCEDCF5), Color(0xFFDDE7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_work_outlined, size: 34, color: Color(0xFF072A73)),
            const SizedBox(height: 8),
            Text(
              '$city, $district',
              style: const TextStyle(color: Color(0xFF1F2430)),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E3E8)),
      ),
      child: child,
    );
  }
}

class _SoftTag extends StatelessWidget {
  const _SoftTag({required this.label, this.isAccent = false});

  final String label;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAccent ? const Color(0xFFF7E9C2) : const Color(0xFFF0F2F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAccent ? const Color(0xFFC8A84B) : const Color(0xFFD6D9E0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isAccent ? const Color(0xFF6A480A) : const Color(0xFF2A3040),
          fontWeight: isAccent ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _ReviewsBlock extends ConsumerWidget {
  const _ReviewsBlock({required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(listingReviewsProvider(listingId));

    return reviewsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (_, _) => const Text(
        'Could not load reviews yet.',
        style: TextStyle(color: Color(0xFF6D7280)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Text(
            'No reviews yet.',
            style: TextStyle(color: Color(0xFF6D7280)),
          );
        }

        final average = items
                .map((item) => item.rating)
                .fold<int>(0, (sum, next) => sum + next) /
            items.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${average.toStringAsFixed(1)} / 5 (${items.length})',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF072A73),
              ),
            ),
            const SizedBox(height: 8),
            ...items.take(3).map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE1E3E8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rating: ${item.rating}/5',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.comment,
                          style: const TextStyle(color: Color(0xFF2A3040)),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}
