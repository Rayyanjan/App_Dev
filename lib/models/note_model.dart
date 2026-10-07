import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String? id;
  final String title;
  final String description;
  final DateTime createdAt;
  Note({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });
  // Converts the Dart object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {'title': title, 'description': description, 'createdAt': createdAt};
  }

  // Converts data coming back from Firestore into a Dart object
  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
