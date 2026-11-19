import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'home_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(productsProvider, (prev, next) {
      if (next.hasValue || next.hasError) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
    ref.watch(productsProvider); // starts the fetch

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}