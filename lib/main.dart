import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart'; 
import 'presentation/providers.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: RoomBookApp()));
}

class RoomBookApp extends StatelessWidget {
  const RoomBookApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'IBA RoomBook',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const AuthGate(),
      );
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(currentUserProvider).when(
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
            data: (user) => user == null ? const AuthScreen() : HomeShell(user: user),
          );
}
