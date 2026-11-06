import 'product.dart';

class ProductState {
 final bool loading;
 final String? error;
 final List<Product> allProducts;
 final List<Product> visibleProducts;
 final List<String> categories;
 final String? selectedCategory;
 const ProductState({
 this.loading = false,
 this.error,
 this.allProducts = const [],
 this.visibleProducts = const [],
 this.categories = const [],
 this.selectedCategory,
 });
 ProductState copyWith({
 bool? loading,
 String? error,
 List<Product>? allProducts,
 List<Product>? visibleProducts,
 List<String>? categories,
 String? selectedCategory,
 bool clearCategory = false,
 }) {
 return ProductState(
 loading: loading ?? this.loading,
 error: error,
 allProducts: allProducts ?? this.allProducts,
 visibleProducts: visibleProducts ?? this.visibleProducts,
 categories: categories ?? this.categories,
 selectedCategory: clearCategory
 ? null
 : (selectedCategory ?? this.selectedCategory),
 );
 }
}