import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';


class ItemException implements Exception {
  final String message;
  ItemException(this.message);
  @override
  String toString() => message;
}

class ItemService {
  ItemService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('items');

  
  Stream<List<Item>> watchItems() => _col.snapshots().map((snap) {
        final items = snap.docs.map(Item.fromDoc).toList();
        items.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return items;
      });

  Stream<Item?> watchItem(String id) =>
      _col.doc(id).snapshots().map((d) => d.exists ? Item.fromDoc(d) : null);

  Future<void> addItem({
    required String title,
    required String category,
    required String location,
    required ItemStatus status,
    required String description,
    required String postedBy,
  }) {
    return _col.add({
      'title': title.trim(),
      'category': category,
      'location': location.trim(),
      'status': status.label,
      'description': description.trim(),
      'postedBy': postedBy.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  
  Future<void> markAsClaimed(String id) {
    final ref = _col.doc(id);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw ItemException('This item no longer exists.');
      }
      if (snap.get('status') == ItemStatus.claimed.label) {
        throw ItemException('This item was already claimed.');
      }
      tx.update(ref, {
        'status': ItemStatus.claimed.label,
        'claimedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteItem(String id) => _col.doc(id).delete();

  
  Future<int> seedIfEmpty() async {
    final existing = await _col.limit(1).get();
    if (existing.docs.isNotEmpty) return 0;

    const seed = [
      ['Black Backpack', 'Bag', 'MCC Cafeteria', 'Found', 'Black backpack with a red zipper, left near the counter.', 'Sara Khan'],
      ['Blue Water Bottle', 'Accessory', 'Library, 2nd Floor', 'Found', 'Blue steel bottle with stickers on the side.', 'Hamza Ahmed'],
      ['Student ID Card — M. Ali', 'ID Card', 'Main Gate', 'Found', 'IBA student ID card belonging to M. Ali. Handed to the guard desk.', 'Guard Desk'],
      ['Laptop Charger (Dell)', 'Electronics', 'Room 301', 'Lost', 'Dell 65W charger with a black cable, lost after a morning lecture.', 'Ayesha Noor'],
      ['Umbrella (Black)', 'Accessory', 'Admin Block', 'Lost', 'Large black umbrella with a wooden handle.', 'Bilal Raza'],
      ['Bunch of Keys', 'Keys', 'Parking Lot', 'Found', 'Three keys on a green keychain with a Honda fob.', 'Usman Tariq'],
      ['Calculus Textbook', 'Book', 'Student Lounge', 'Lost', 'Thomas\' Calculus, name written on the first page.', 'Fatima Zahid'],
      ['Grey Jacket', 'Clothing', 'Auditorium', 'Found', 'Grey zip-up hoodie, size M, left on a seat in row 4.', 'Danish Iqbal'],
    ];

    final batch = _db.batch();
    final now = DateTime.now();
    for (var i = 0; i < seed.length; i++) {
      final s = seed[i];
      batch.set(_col.doc(), {
        'title': s[0],
        'category': s[1],
        'location': s[2],
        'status': s[3],
        'description': s[4],
        'postedBy': s[5],
       
        'createdAt': Timestamp.fromDate(now.subtract(Duration(minutes: i))),
      });
    }
    await batch.commit();
    return seed.length;
  }
}
