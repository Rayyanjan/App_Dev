import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firebase_auth_repository.dart';
import '../data/firestore_booking_repository.dart';
import '../data/firestore_room_repository.dart';
import '../domain/app_models.dart';
import '../domain/booking.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);


final bookingRepositoryProvider = Provider<BookingRepository>(
    (ref) => FirestoreBookingRepository(FirebaseFirestore.instance));
final roomRepositoryProvider =
    Provider<RoomRepository>((ref) => FirestoreRoomRepository(FirebaseFirestore.instance));
final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => FirebaseAuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance));


final currentUserProvider =
    StreamProvider<AppUser?>((ref) => ref.watch(authRepositoryProvider).watchCurrentUser());

final roomsProvider =
    StreamProvider<List<Room>>((ref) => ref.watch(roomRepositoryProvider).watchRooms());

final selectedDateProvider = StateProvider<DateTime>((ref) => dateOnly(DateTime.now()));

typedef RoomDay = ({String roomId, DateTime day}); 

final roomDayBookingsProvider = StreamProvider.family<List<Booking>, RoomDay>(
    (ref, k) => ref.watch(bookingRepositoryProvider).watchRoomDay(k.roomId, k.day));

final myBookingsProvider = StreamProvider.family<List<Booking>, String>(
    (ref, uid) => ref.watch(bookingRepositoryProvider).watchMyBookings(uid));


class BookingActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> book({required String roomId, required DateTime slotStart,
      required String userId, required String userName}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(bookingRepositoryProvider)
        .book(roomId: roomId, slotStart: slotStart, userId: userId, userName: userName));
  }

  Future<void> cancel(Booking b) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(bookingRepositoryProvider).cancel(b));
  }
}

final bookingActionProvider =
    AsyncNotifierProvider<BookingActionNotifier, void>(BookingActionNotifier.new);


class AuthActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  void _checkDomain(String email) {
    if (!Validators.isAllowedEmail(email)) throw InvalidEmailDomainException();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _checkDomain(email);
      await ref.read(authRepositoryProvider)
          .signIn(email: email.trim(), password: password);
    });
  }

  Future<void> signUp(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _checkDomain(email);
      await ref.read(authRepositoryProvider)
          .signUp(name: name.trim(), email: email.trim(), password: password);
    });
  }

  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();
}

final authActionProvider =
    AsyncNotifierProvider<AuthActionNotifier, void>(AuthActionNotifier.new);


class PastState {
  final List<Booking> items;
  final Object? cursor;
  final bool hasMore;
  const PastState(this.items, this.cursor, this.hasMore);
}

class PastBookingsNotifier extends FamilyAsyncNotifier<PastState, String> {
  @override
  Future<PastState> build(String arg) async {
    final p = await ref.read(bookingRepositoryProvider).fetchPast(arg);
    return PastState(p.items, p.cursor, p.hasMore);
  }

  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || !cur.hasMore) return;
    state = await AsyncValue.guard(() async {
      final p = await ref.read(bookingRepositoryProvider).fetchPast(arg, cursor: cur.cursor);
      return PastState([...cur.items, ...p.items], p.cursor, p.hasMore);
    });
  }
}

final pastBookingsProvider =
    AsyncNotifierProvider.family<PastBookingsNotifier, PastState, String>(
        PastBookingsNotifier.new);
