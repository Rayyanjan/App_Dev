import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/app_models.dart';

class FirestoreRoomRepository implements RoomRepository {
  FirestoreRoomRepository(this._db);
  final FirebaseFirestore _db;

  @override
  Stream<List<Room>> watchRooms() => _db.collection('rooms').orderBy('name').snapshots().map(
      (s) => s.docs.map((d) {
            final m = d.data();
            return Room(id: d.id, name: m['name'], floor: (m['floor'] as num).toInt(),
                capacity: (m['capacity'] as num).toInt());
          }).toList());
}
