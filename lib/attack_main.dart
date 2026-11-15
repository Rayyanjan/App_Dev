
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

const _email = String.fromEnvironment('EMAIL');
const _pass = String.fromEnvironment('PASS');

/// Runs [fn]. If [shouldSucceed] is false, a permission-denied error is the PASS result.
Future<String> check(String label, Future<void> Function() fn,
    {required bool shouldSucceed}) async {
  try {
    await fn();
    return shouldSucceed
        ? 'PASS  - $label: allowed (as expected)'
        : 'FAIL  - $label: was ALLOWED but should be blocked!';
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      return shouldSucceed
          ? 'FAIL  - $label: blocked but should be allowed'
          : 'PASS  - $label: blocked (permission-denied)';
    }
    return 'FAIL  - $label: unexpected error ${e.code}';
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final db = FirebaseFirestore.instance;
  final out = <String>[];

  if (_email.isEmpty || _pass.isEmpty) {
    out.add('Pass --dart-define=EMAIL=... --dart-define=PASS=...');
  } else {
   try {
    final cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: _email, password: _pass);
    final uid = cred.user!.uid;
    final me = await db.collection('users').doc(uid).get();
    out.add('Signed in as $_email (role in DB: ${me.data()?['role']})');
    if (me.data()?['role'] == 'admin') {
      out.add('WARNING: this is an ADMIN account - use a student account for this test');
    }

    out.add(await check('student sets OWN role to admin',
        () => db.collection('users').doc(uid).update({'role': 'admin'}),
        shouldSucceed: false));

    out.add(await check('student edits OWN name',
        () => db.collection('users').doc(uid).update({'name': me.data()?['name'] ?? 'Student'}),
        shouldSucceed: true));

    final others = await db.collection('bookings')
        .where('userId', isNotEqualTo: uid).limit(1).get();
    if (others.docs.isEmpty) {
      out.add('SKIP  - cancel another student\'s booking (no other booking exists; make one with another account)');
    } else {
      out.add(await check("student cancels ANOTHER student's booking",
          () => others.docs.first.reference.update({'status': 'cancelled'}),
          shouldSucceed: false));
    }

    out.add(await check('student creates booking with SOMEONE ELSE\'s userId',
        () => db.collection('bookings').add({
              'roomId': 'Room-9200-1', 'userId': 'someone-else', 'userName': 'x',
              'status': 'active', 'slotStart': Timestamp.now(), 'slotEnd': Timestamp.now(),
            }),
        shouldSucceed: false));

    final mine = await db.collection('bookings')
        .where('userId', isEqualTo: uid).limit(1).get();
    if (mine.docs.isEmpty) {
      out.add('SKIP  - delete own booking (you have no bookings; make one first)');
    } else {
      out.add(await check('student DELETES own booking',
          () => mine.docs.first.reference.delete(), shouldSucceed: false));
    }

    out.add(await check('student edits a room',
        () => db.collection('rooms').doc('Room-9200-1').update({'capacity': 99}),
        shouldSucceed: false));
   } catch (e) {
     out.add('ERROR (check email/password, or the console): $e');
   }
  }

  for (final l in out) {
    debugPrint(l);
  }
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: Padding(padding: const EdgeInsets.all(24),
          child: Text(out.join('\n\n')))),
    ),
  ));
}
