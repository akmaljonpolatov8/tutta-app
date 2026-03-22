import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _FavoriteTile(
            title: 'The Glass Pavilion',
            subtitle: 'Malibu-inspired • 4.9 • \$450/night',
          ),
          const SizedBox(height: 8),
          const _FavoriteTile(
            title: 'Azure Cliffside',
            subtitle: 'Santorini style • 4.8 • \$690/night',
          ),
          const SizedBox(height: 8),
          const _FavoriteTile(
            title: 'Nordic Retreat',
            subtitle: 'Loften cozy • 4.7 • \$230/night',
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => context.go(RouteNames.search),
            icon: const Icon(Icons.search_outlined),
            label: const Text('Discover more stays'),
          ),
        ],
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.favorite, color: Colors.redAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
