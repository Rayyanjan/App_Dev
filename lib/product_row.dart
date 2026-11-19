import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product.dart';
import 'providers.dart';
import 'product_detail_screen.dart';

class ProductRow extends ConsumerWidget {
  final Product product;
  const ProductRow(this.product, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(product.id);

    return ListTile(
      leading: Image.network(product.image, width: 48),
      title: Text(product.title,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('\$${product.price}'),
      trailing: IconButton(
        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
        onPressed: () =>
            ref.read(favoritesProvider.notifier).toggle(product.id),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product)),
      ),
    );
  }
}