import 'package:flutter_test/flutter_test.dart';
import 'package:class_activity/favorites_cubit.dart';

void main() {
  group('FavoritesCubit', () {
    late FavoritesCubit cubit;
    setUp(() => cubit = FavoritesCubit());
    tearDown(() => cubit.close());

    test('toggle adds then removes an id', () {
      cubit.toggle(1);
      expect(cubit.state, {1});
      cubit.toggle(1);
      expect(cubit.state, <int>{});
    });
  });
}