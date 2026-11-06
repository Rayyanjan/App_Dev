import 'package:flutter_bloc/flutter_bloc.dart';
import 'api_service.dart';
import 'product_event.dart';
import 'product_state.dart';
class ProductBloc extends Bloc<ProductEvent, ProductState> {
 final ApiService api;
 ProductBloc(this.api) : super(const ProductState()) {
 on<LoadProducts>(_onLoad);
 on<FilterByCategory>(_onFilter);
 on<SearchProducts>(_onSearch);
 }
 Future<void> _onLoad(LoadProducts e, Emitter<ProductState> emit) async {
 emit(state.copyWith(loading: true, error: null));
 try {
 final products = await api.fetchAllProducts();
 final categories = await api.fetchCategories();
 emit(state.copyWith(
 loading: false,
 allProducts: products,
 visibleProducts: products,
 categories: categories,
 ));
 } catch (_) {
 emit(state.copyWith(loading: false, error: 'Failed to load products'));
 }
 }
 void _onFilter(FilterByCategory e, Emitter<ProductState> emit) {
 final filtered = e.category == null
 ? state.allProducts
 : state.allProducts.where((p) => p.category == e.category).toList();
 emit(state.copyWith(
 selectedCategory: e.category,
 clearCategory: e.category == null,
 visibleProducts: filtered,
 ));
 }
 void _onSearch(SearchProducts e, Emitter<ProductState> emit) {
 final base = state.selectedCategory == null
 ? state.allProducts
 : state.allProducts
 .where((p) => p.category == state.selectedCategory)
 .toList();
 final filtered = e.query.isEmpty
 ? base
 : base
 .where((p) =>
 p.title.toLowerCase().contains(e.query.toLowerCase()))
 .toList();
 emit(state.copyWith(visibleProducts: filtered));
 }
}