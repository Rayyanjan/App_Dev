const kSlotMinutes = 30; 
const kMaxActiveBookings = 2;
const kDayStartHour = 9;
const kDayEndHour = 21;
const kSlotsPerDay = (kDayEndHour - kDayStartHour) * 60 ~/ kSlotMinutes; // 24 at 30 min
const kPageSize = 10;

class Booking {
  final String id, roomId, userId, userName, status;
  final DateTime slotStart, slotEnd;
  const Booking({required this.id, required this.roomId, required this.userId,
    required this.userName, required this.status,
    required this.slotStart, required this.slotEnd});

 
  String effectiveStatus(DateTime now) =>
      status == 'active' && slotEnd.isBefore(now) ? 'expired' : status;
}

class BookingPolicy {
  
  static bool isLive(String status, DateTime slotEnd, DateTime now) =>
      status == 'active' && slotEnd.isAfter(now);

  static int countLive(Iterable<Booking> bs, DateTime now) =>
      bs.where((b) => isLive(b.status, b.slotEnd, now)).length;

  static String slotId(String roomId, DateTime slotStart) =>
      '${roomId}_${slotStart.toUtc().millisecondsSinceEpoch}';
}

class SlotTakenException implements Exception {
  @override String toString() => 'Someone just booked this — pick another slot';
}
class BookingLimitException implements Exception {
  @override String toString() => 'You already have 2 active bookings';
}
class SlotInPastException implements Exception {
  @override String toString() => 'That slot has already ended';
}

abstract class BookingRepository {
  Future<void> book({required String roomId, required DateTime slotStart,
      required String userId, required String userName});
  Future<void> cancel(Booking booking); 
  Stream<List<Booking>> watchRoomDay(String roomId, DateTime day);
  
  Stream<List<Booking>> watchMyBookings(String userId);
 
  Future<PastPage> fetchPast(String userId, {Object? cursor});
}

class PastPage {
  final List<Booking> items;
  final Object? cursor;
  final bool hasMore;
  const PastPage(this.items, this.cursor, this.hasMore);
}
