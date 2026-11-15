import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/booking.dart';

class FirestoreBookingRepository implements BookingRepository {
  FirestoreBookingRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _bookings => _db.collection('bookings');
  CollectionReference<Map<String, dynamic>> get _locks => _db.collection('slotLocks');
  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  Booking _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return Booking(
      id: d.id, roomId: m['roomId'], userId: m['userId'], userName: m['userName'],
      status: m['status'],
      slotStart: (m['slotStart'] as Timestamp).toDate(),
      slotEnd: (m['slotEnd'] as Timestamp).toDate(),
    );
  }

 
  @override
  Future<void> book({required String roomId, required DateTime slotStart,
      required String userId, required String userName}) async {
    final slotEnd = slotStart.add(const Duration(minutes: kSlotMinutes));
    final now = DateTime.now();
    if (!slotEnd.isAfter(now)) throw SlotInPastException();

    final lockRef = _locks.doc(BookingPolicy.slotId(roomId, slotStart));
    final userRef = _users.doc(userId);
    final newRef = _bookings.doc();

    await _db.runTransaction((tx) async {
      
      final lock = await tx.get(lockRef);
      if (lock.exists) throw SlotTakenException();

      final userSnap = await tx.get(userRef);
      final ids = List<String>.from(userSnap.data()?['activeBookingIds'] ?? []);
      final live = <String>[];
      for (final id in ids) {
        final b = await tx.get(_bookings.doc(id));
        if (!b.exists) continue;
        final m = b.data()!;
        if (BookingPolicy.isLive(m['status'], (m['slotEnd'] as Timestamp).toDate(), now)) {
          live.add(id);
        }
      }
      if (live.length >= kMaxActiveBookings) throw BookingLimitException();

      final data = {
        'roomId': roomId, 'userId': userId, 'userName': userName,
        'status': 'active',
        'slotStart': Timestamp.fromDate(slotStart),
        'slotEnd': Timestamp.fromDate(slotEnd),
        'date': DateTime(slotStart.year, slotStart.month, slotStart.day)
            .toIso8601String().substring(0, 10),
        'createdAt': FieldValue.serverTimestamp(),
      };
      tx.set(newRef, data);
      tx.set(lockRef, {'bookingId': newRef.id, 'userId': userId});
      tx.set(userRef, {'activeBookingIds': [...live, newRef.id]}, SetOptions(merge: true));
    });
  }

  @override
  Future<void> cancel(Booking b) async {
    final batch = _db.batch();
    batch.update(_bookings.doc(b.id),
        {'status': 'cancelled', 'cancelledAt': FieldValue.serverTimestamp()});
    batch.delete(_locks.doc(BookingPolicy.slotId(b.roomId, b.slotStart))); 
    await batch.commit(); 
  }

  @override
  Stream<List<Booking>> watchRoomDay(String roomId, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
   
    return _bookings
        .where('roomId', isEqualTo: roomId)
        .where('status', isEqualTo: 'active')
        .where('slotStart', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('slotStart', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  @override
  Stream<List<Booking>> watchMyBookings(String userId) => _bookings
      .where('userId', isEqualTo: userId)
      .where('slotEnd', isGreaterThan: Timestamp.now())
      .orderBy('slotEnd')
      .snapshots()
      .map((s) => s.docs.map(_fromDoc).toList());

  @override
  Future<PastPage> fetchPast(String userId, {Object? cursor}) async {
    Query<Map<String, dynamic>> q = _bookings
        .where('userId', isEqualTo: userId)
        .where('slotEnd', isLessThan: Timestamp.now())
        .orderBy('slotEnd', descending: true)
        .limit(kPageSize);
    if (cursor != null) {
      q = q.startAfterDocument(cursor as DocumentSnapshot<Map<String, dynamic>>);
    }
    final snap = await q.get();
    return PastPage(
      snap.docs.map(_fromDoc).toList(),
      snap.docs.isEmpty ? cursor : snap.docs.last,
      snap.docs.length == kPageSize,
    );
  }
}
