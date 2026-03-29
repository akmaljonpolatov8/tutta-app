import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../listings/application/search_controller.dart';
import '../../../listings/domain/models/listing.dart';
import '../../application/favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(favoritesIdsProvider).toList(growable: false);
    final listingsFuture = Future.wait(
      ids.map((id) => ref.read(listingsRepositoryProvider).getById(id)),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(RouteNames.home),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Favorites'),
      ),
      body: ids.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'No favorites yet. Save listings with the heart icon and they will appear here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : FutureBuilder<List<Listing?>>(
              future: listingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final listings = (snapshot.data ?? const <Listing?>[])
                    .whereType<Listing>()
                    .toList(growable: false);
                if (listings.isEmpty) {
                  return const Center(
                    child: Text('No available favorites right now.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: listings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = listings[index];
                    return _FavoriteTile(listing: item);
                  },
                );
              },
            ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  const _FavoriteTile({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesIdsProvider.select((ids) => ids.contains(listing.id)),
    );
    final imageUrl = listing.imageUrls.isEmpty ? null : listing.imageUrls.first;
    final rating = _mockRatingFor(listing.id);
    final reviews = _mockReviewsFor(listing.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('${RouteNames.listingDetails}/${listing.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.7,
                  child: imageUrl == null
                      ? Container(
                          color: const Color(0xFFE9EEF8),
                          alignment: Alignment.center,
                          child: const Icon(Icons.home_work_outlined, size: 34),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFFE9EEF8),
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xEDFFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _typeLabel(listing.type),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF273250),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () =>
                        ref.read(favoritesIdsProvider.notifier).toggle(listing.id),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFFD64545),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2F7B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$reviews reviews',
                        style: const TextStyle(color: Color(0xFF657089)),
                      ),
                      const Spacer(),
                      Text(
                        listing.nightlyPriceUzs == null
                            ? 'Free stay'
                            : '${_formatUzs(listing.nightlyPriceUzs!)} UZS',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6A480A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.city}, ${listing.district}',
                    style: const TextStyle(color: Color(0xFF58637B)),
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

String _typeLabel(ListingType type) {
  switch (type) {
    case ListingType.apartment:
      return 'Apartment';
    case ListingType.room:
      return 'Room';
    case ListingType.homePart:
      return 'Home Part';
    case ListingType.freeStay:
      return 'Free Stay';
  }
}

double _mockRatingFor(String id) {
  final hash = id.codeUnits.fold<int>(0, (a, b) => a + b);
  final delta = (hash % 9) / 10.0;
  return (4.1 + delta).clamp(4.1, 4.9);
}

int _mockReviewsFor(String id) {
  final hash = id.codeUnits.fold<int>(0, (a, b) => a + b);
  return 10 + (hash % 90);
}

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
  return out.toString();
}
