import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/workout/presentation/screens/workout_screen.dart';

void main() {
  runApp(const ProviderScope(child: KajiFitApp()));
}

class KajiFitApp extends StatelessWidget {
  const KajiFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaji-Fit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WorkoutScreen(),
    );
  }
}
