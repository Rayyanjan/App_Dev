import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:class_activity/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('search, filter, favorite, and find it again',
      (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.enterText(find.byType(TextField), 'shirt');
    await tester.pumpAndSettle();
    expect(find.byType(app.ProductCard), findsWidgets);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    await tester.tap(find.text('electronics').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(app.ProductCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(app.ProductDetailScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(
      of: find.byType(AppBar),
      matching: find.byIcon(Icons.favorite),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsWidgets);
  });
}