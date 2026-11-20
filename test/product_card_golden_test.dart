import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:class_activity/main.dart';
import 'package:class_activity/product.dart';
import 'package:class_activity/favorites_cubit.dart';

void main() {
  testWidgets('ProductCard matches its golden file', (tester) async {
    await mockNetworkImagesFor(() async {
      const product = Product(
        id: 1, title: 'Mock Shirt', description: '',
        price: 9.99, category: 'clothing', image: '', rating: 4.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => FavoritesCubit(),
            child: const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  height: 300,
                  child: ProductCard(product: product),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ProductCard),
        matchesGoldenFile('goldens/product_card.png'),
      );
    });
  });
}