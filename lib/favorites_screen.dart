import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoritesProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: productsAsync.when(
        data: (all) {
          final favs = all.where((p) => favIds.contains(p.id)).toList();
          if (favs.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: favs.length,
                itemBuilder: (_, i) {
                  final p = favs[i];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        children: [
                          Image.network(p.image, height: 100),
                          Text(p.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('\$${p.price}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}