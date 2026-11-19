import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'product.dart';
import 'product_row.dart';
import 'favorites_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);

    return categoriesAsync.when(
      data: (cats) {
        final tabs = ['All', ...cats];
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Fakestore Deals'),
              bottom: TabBar(
                isScrollable: true,
                tabs: tabs.map((t) => Tab(text: t)).toList(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FavoritesScreen()),
                  ),
                ),
              ],
            ),
            body: productsAsync.when(
              data: (allProducts) => TabBarView(
                children: tabs.map((tab) {
                  final List<Product> list = tab == 'All'
                      ? List.of(allProducts)
                      : allProducts.where((p) => p.category == tab).toList();
                  list.sort((a, b) => b.rating.compareTo(a.rating));
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) => ProductRow(list[i]),
                  );
                }).toList(),
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}