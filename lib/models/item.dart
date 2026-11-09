import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemStatus {
  lost('Lost'),
  found('Found'),
  claimed('Claimed');

  const ItemStatus(this.label);
  final String label;

  static ItemStatus fromLabel(String? v) => ItemStatus.values.firstWhere(
        (s) => s.label.toLowerCase() == (v ?? '').toLowerCase(),
        orElse: () => ItemStatus.found,
      );
}

const itemCategories = [
  'Bag', 'Accessory', 'ID Card', 'Electronics', 'Keys', 'Book', 'Clothing', 'Other',
];

class Item {
  final String id;
  final String title;
  final String category;
  final String location;
  final ItemStatus status;
  final String description;
  final String postedBy;
  final DateTime? createdAt;

  const Item({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.status,
    required this.description,
    required this.postedBy,
    this.createdAt,
  });

  factory Item.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Item(
      id: doc.id,
      title: d['title'] as String? ?? '',
      category: d['category'] as String? ?? 'Other',
      location: d['location'] as String? ?? '',
      status: ItemStatus.fromLabel(d['status'] as String?),
      description: d['description'] as String? ?? '',
      postedBy: d['postedBy'] as String? ?? 'Anonymous',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
