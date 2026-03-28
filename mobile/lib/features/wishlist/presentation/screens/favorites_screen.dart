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
              child: Text('No favorites yet. Add listings with the heart icon.'),
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

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Text(listing.title),
        subtitle: Text('${listing.city}, ${listing.district}'),
        trailing: IconButton(
          onPressed: () =>
              ref.read(favoritesIdsProvider.notifier).toggle(listing.id),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: const Color(0xFFD64545),
          ),
        ),
        onTap: () => context.push('${RouteNames.listingDetails}/${listing.id}'),
      ),
    );
  }
}
