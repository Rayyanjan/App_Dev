import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:class_activity/product.dart';
import 'package:class_activity/product_bloc.dart';
import 'package:class_activity/product_event.dart';
import 'package:class_activity/product_state.dart';
import 'mocks.dart';

void main() {
  group('ProductBloc', () {
    late MockApiService mockApi;

    setUp(() {
      mockApi = MockApiService();
      when(() => mockApi.fetchAllProducts()).thenAnswer(
        (_) async => const [
          Product(id: 1, title: 'Mock Shirt', description: '',
              price: 9.99, category: 'clothing', image: '', rating: 4.0),
          Product(id: 2, title: 'Mock Watch', description: '',
              price: 49.99, category: 'electronics', image: '', rating: 4.5),
        ],
      );
      when(() => mockApi.fetchCategories())
          .thenAnswer((_) async => ['clothing', 'electronics']);
    });

    test('LoadProducts loads 2 mocked products', () async {
      final bloc = ProductBloc(mockApi);
      bloc.add(LoadProducts());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<ProductState>(
            (s) => !s.loading && s.allProducts.length == 2)),
      );
      verify(() => mockApi.fetchAllProducts()).called(1);
      await bloc.close();
    });

    test('FilterByCategory narrows visibleProducts', () async {
      final bloc = ProductBloc(mockApi);
      bloc.add(LoadProducts());
      await expectLater(bloc.stream,
          emitsThrough(predicate<ProductState>((s) => !s.loading)));
      bloc.add(FilterByCategory('electronics'));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<ProductState>((s) =>
            s.visibleProducts.length == 1 &&
            s.visibleProducts.first.category == 'electronics')),
      );
      await bloc.close();
    });
  });
}