import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/quizzes/quizzes_bloc.dart';
import '../blocs/quizzes/quizzes_event.dart';
import '../blocs/quizzes/quizzes_state.dart';
import 'quiz_taking_screen.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Quizzes')),
      body: BlocBuilder<QuizzesBloc, QuizzesState>(
        builder: (context, state) {
          if (state is QuizzesLoading) return const Center(child: CircularProgressIndicator());
          if (state is QuizzesLoaded) {
            final quizzes = state.quizzes;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<QuizzesBloc>().add(RefreshQuizzesEvent());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemBuilder: (ctx, i) {
                  final q = quizzes[i];
                  return ListTile(
                    title: Text(q.title),
                    subtitle: Text(q.description ?? ''),
                    trailing: ElevatedButton(
                      child: const Text('Take'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => QuizTakingScreen(quizId: q.id!)));
                      },
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: quizzes.length,
              ),
            );
          }
          if (state is QuizzesError) return Center(child: Text('Error: ${state.message}'));
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
