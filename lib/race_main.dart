import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'data/firestore_booking_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final repo = FirestoreBookingRepository(FirebaseFirestore.instance);

  final d = DateTime.now().add(const Duration(days: 2));
  final slot = DateTime(d.year, d.month, d.day, 10); 

  Future<String> attempt(String who) async {
    try {
      await repo.book(roomId: 'Room-9200-5', slotStart: slot, userId: who, userName: who);
      return '$who: SUCCESS';
    } catch (e) {
      return '$who: FAILED -> $e';
    }
  }

  final results = await Future.wait([attempt('raceA'), attempt('raceB')]);
  for (final r in results) {
    debugPrint(r);
  }
  runApp(MaterialApp(
    home: Scaffold(body: Center(child: Text(results.join('\n\n')))),
  ));
}
