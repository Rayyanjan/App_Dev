import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roombook/domain/booking.dart';
import 'package:roombook/presentation/providers.dart';


class FakeRepo implements BookingRepository {
  final taken = <String>{};
  final Map<String, List<DateTime>> liveByUser = {}; 
  @override
  Future<void> book({required String roomId, required DateTime slotStart,
      required String userId, required String userName}) async {
    final id = BookingPolicy.slotId(roomId, slotStart);
    if (taken.contains(id)) throw SlotTakenException();
    final mine = liveByUser[userId] ?? [];
    final now = DateTime.now();
    if (mine.where((e) => e.isAfter(now)).length >= kMaxActiveBookings) {
      throw BookingLimitException();
    }
    taken.add(id);
    liveByUser[userId] = [...mine, slotStart.add(const Duration(minutes: kSlotMinutes))];
  }
  @override Future<void> cancel(Booking b) async {}
  @override Future<PastPage> fetchPast(String u, {Object? cursor}) async => const PastPage([], null, false);
  @override Stream<List<Booking>> watchRoomDay(String r, DateTime d) => const Stream.empty();
  @override Stream<List<Booking>> watchMyBookings(String u) => const Stream.empty();
}

ProviderContainer make(FakeRepo r) {
  final c = ProviderContainer(overrides: [bookingRepositoryProvider.overrideWithValue(r)]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  final t = DateTime.now().add(const Duration(days: 1));
  Future<void> book(ProviderContainer c, String user, DateTime s) =>
      c.read(bookingActionProvider.notifier)
          .book(roomId: 'r1', slotStart: s, userId: user, userName: user);

  test('slot already taken surfaces SlotTakenException as AsyncError', () async {
    final c = make(FakeRepo());
    await book(c, 'a', t);
    await book(c, 'b', t);
    final s = c.read(bookingActionProvider);
    expect(s.hasError, true);
    expect(s.error, isA<SlotTakenException>());
  });

  test('third active booking is rejected', () async {
    final c = make(FakeRepo());
    await book(c, 'a', t);
    await book(c, 'a', t.add(const Duration(hours: 1)));
    await book(c, 'a', t.add(const Duration(hours: 2)));
    expect(c.read(bookingActionProvider).error, isA<BookingLimitException>());
  });

  test('successful booking ends in AsyncData', () async {
    final c = make(FakeRepo());
    await book(c, 'a', t);
    expect(c.read(bookingActionProvider).hasError, false);
  });

  test('policy ignores cancelled and expired bookings in the cap', () {
    final now = DateTime(2026, 1, 1, 12);
    Booking b(String st, DateTime end) => Booking(id: 'x', roomId: 'r', userId: 'u',
        userName: 'u', status: st, slotStart: end.subtract(const Duration(minutes: 30)), slotEnd: end);
    final list = [
      b('active', now.add(const Duration(hours: 1))),
      b('active', now.subtract(const Duration(hours: 1))), 
      b('cancelled', now.add(const Duration(hours: 2))),
    ];
    expect(BookingPolicy.countLive(list, now), 1);
    expect(list[1].effectiveStatus(now), 'expired');
  });
}
