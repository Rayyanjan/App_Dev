import 'package:flutter_bloc/flutter_bloc.dart';
class FavoritesCubit extends Cubit<Set<int>> {
 FavoritesCubit() : super(<int>{});
 void toggle(int productId) {
 final next = Set<int>.from(state);
 next.contains(productId) ? next.remove(productId) : next.add(productId);
 emit(next);
 }
}
