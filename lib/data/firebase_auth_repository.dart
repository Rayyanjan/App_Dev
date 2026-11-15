import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/app_models.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  
  @override
  Stream<AppUser?> watchCurrentUser() =>
      _auth.authStateChanges().asyncExpand<AppUser?>((u) {
        if (u == null) return Stream<AppUser?>.value(null);
        return _db.collection('users').doc(u.uid).snapshots().map((d) {
          final m = d.data();
          return AppUser(
            uid: u.uid,
            name: (m?['name'] as String?) ?? u.email ?? '',
            email: u.email ?? '',
            role: (m?['role'] as String?) ?? 'student',
          );
        });
      });

  @override
  Future<void> signUp({required String name, required String email, required String password}) async {
    try {
      final c = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _db.collection('users').doc(c.user!.uid).set({
        'uid': c.user!.uid, 'name': name, 'email': email,
        'role': 'student', 'activeBookingIds': <String>[],
      });
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? e.code);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? e.code);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
