import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 
import 'api_service.dart';
import 'favorites_cubit.dart';
import 'product.dart';
import 'product_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';
 
void main() => runApp(const MyApp());
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductBloc(ApiService())..add(LoadProducts()),
        ),
        BlocProvider(create: (_) => FavoritesCubit()),
      ],
      child: const MaterialApp(home: SplashScreen()),
    );
  }
}
 
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (!state.loading && state.allProducts.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        },
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
 
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (q) =>
                  context.read<ProductBloc>().add(SearchProducts(q)),
            ),
          ),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              return SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: state.selectedCategory == null,
                      onSelected: (_) => context
                          .read<ProductBloc>()
                          .add(FilterByCategory(null)),
                    ),
                    ...state.categories.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text(c),
                          selected: state.selectedCategory == c,
                          onSelected: (_) => context
                              .read<ProductBloc>()
                              .add(FilterByCategory(c)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(child: Text(state.error!));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: state.visibleProducts.length,
                  itemBuilder: (context, i) =>
                      _ProductCard(product: state.visibleProducts[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
 
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: Image.network(product.image, fit: BoxFit.contain),
            ),
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('\$${product.price}'),
            BlocBuilder<FavoritesCubit, Set<int>>(
              builder: (context, favs) {
                final isFav = favs.contains(product.id);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null,
                  ),
                  onPressed: () =>
                      context.read<FavoritesCubit>().toggle(product.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
 
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.network(product.image, height: 220)),
            const SizedBox(height: 16),
            Text(
              product.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '\$${product.price}',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                Text(' ${product.rating}'),
              ],
            ),
            const SizedBox(height: 12),
            Text(product.description),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, productState) {
          return BlocBuilder<FavoritesCubit, Set<int>>(
            builder: (context, favIds) {
              final favs = productState.allProducts
                  .where((p) => favIds.contains(p.id))
                  .toList();
              if (favs.isEmpty) {
                return const Center(child: Text('No favorites yet'));
              }
              return ListView.builder(
                itemCount: favs.length,
                itemBuilder: (context, i) {
                  final product = favs[i];
                  return ListTile(
                    leading: Image.network(product.image, width: 40),
                    title: Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('\$${product.price}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
 