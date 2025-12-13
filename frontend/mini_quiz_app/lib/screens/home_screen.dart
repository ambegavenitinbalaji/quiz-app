import 'package:flutter/material.dart';
import 'quiz_builder_screen.dart';
import 'quiz_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Quiz — Home')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.create),
              label: const Text('Quiz Builder (Admin)'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizBuilderScreen())),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Browse Quizzes / Take Quiz'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizListScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
