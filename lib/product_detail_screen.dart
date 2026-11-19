import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product.dart';
import 'providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  final Product product;
  const ProductDetailScreen(this.product, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(product.id);

    return Scaffold(
      appBar: AppBar(title: Text(product.title, maxLines: 1)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.network(product.image, height: 220)),
            const SizedBox(height: 16),
            Text(product.title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text('\$${product.price}',
                style: const TextStyle(fontSize: 18, color: Colors.green)),
            Text('Rating: ${product.rating} / 5'),
            const SizedBox(height: 12),
            Text(product.description),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
              label: Text(isFav ? 'Remove Favorite' : 'Add to Favorites'),
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).toggle(product.id),
            ),
          ],
        ),
      ),
    );
  }
}