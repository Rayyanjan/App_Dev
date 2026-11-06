abstract class ProductEvent {}
class LoadProducts extends ProductEvent {}
class FilterByCategory extends ProductEvent {
 final String? category; // null = All
 FilterByCategory(this.category);
}
class SearchProducts extends ProductEvent {
 final String query;
 SearchProducts(this.query);
}
