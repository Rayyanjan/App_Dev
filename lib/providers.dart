import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'product.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.read(apiServiceProvider).fetchAllProducts();
});

final categoriesProvider = FutureProvider<List<String>>((ref) {
  return ref.read(apiServiceProvider).fetchCategories();
});

final selectedTabProvider = StateProvider<int>((ref) => 0);

class FavoritesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};

  void toggle(int id) {
    state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);