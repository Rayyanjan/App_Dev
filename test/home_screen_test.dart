import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:class_activity/main.dart';
import 'package:class_activity/product.dart';
import 'package:class_activity/favorites_cubit.dart';
import 'package:class_activity/product_bloc.dart';
import 'package:class_activity/product_event.dart';
import 'mocks.dart';

void main() {
  testWidgets('shows mocked products; search and favorite work',
      (tester) async {
    // Phone-sized screen so the cards and their hearts are visible.
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await mockNetworkImagesFor(() async {
      final mockApi = MockApiService();
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

      final productBloc = ProductBloc(mockApi)..add(LoadProducts());
      final favoritesCubit = FavoritesCubit();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productBloc),
            BlocProvider.value(value: favoritesCubit),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mock Shirt'), findsOneWidget);
      expect(find.text('Mock Watch'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'watch');
      await tester.pumpAndSettle();
      expect(find.text('Mock Watch'), findsOneWidget);
      expect(find.text('Mock Shirt'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pump();
      expect(favoritesCubit.state, {1});
    });
  });
}