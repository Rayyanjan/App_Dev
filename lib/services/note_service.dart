import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class NoteService {
  final CollectionReference notesRef = FirebaseFirestore.instance.collection(
    'notes',
  );
  // CREATE: adds a new note
  Future<void> addNote(Note note) async {
    await notesRef.add(note.toMap());
  }

  // READ: returns a real-time stream of all notes
  Stream<List<Note>> getNotes() {
    return notesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Note.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  // UPDATE: updates an existing note
  Future<void> updateNote(String id, Note note) async {
    await notesRef.doc(id).update(note.toMap());
  }

  // DELETE: removes a note
  Future<void> deleteNote(String id) async {
    await notesRef.doc(id).delete();
  }
}
