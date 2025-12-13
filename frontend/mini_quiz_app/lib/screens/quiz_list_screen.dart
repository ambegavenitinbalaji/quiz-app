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
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Available Quizzes',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<QuizzesBloc, QuizzesState>(
        builder: (context, state) {
          if (state is QuizzesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuizzesError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is QuizzesLoaded) {
            final quizzes = state.quizzes;

            if (quizzes.isEmpty) {
              return const Center(
                child: Text(
                  'No quizzes available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<QuizzesBloc>().add(RefreshQuizzesEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: quizzes.length,
                itemBuilder: (ctx, i) {
                  final q = quizzes[i];

                  return _QuizTile(
                    title: q.title,
                    description: q.description,
                    onTake: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizTakingScreen(quizId: q.id!),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _QuizTile extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback onTake;

  const _QuizTile({
    required this.title,
    this.description,
    required this.onTake,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            /// Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.quiz, color: Colors.green),
            ),

            const SizedBox(width: 14),

            /// Title + Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (description != null && description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// Take Button
            ElevatedButton(
              onPressed: onTake,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text('Take'),
            ),
          ],
        ),
      ),
    );
  }
}
