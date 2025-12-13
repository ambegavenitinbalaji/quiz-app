import 'package:flutter/material.dart';
import 'quiz_editor_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/quizzes/quizzes_bloc.dart';
import '../blocs/quizzes/quizzes_state.dart';
import '../models/quiz.dart';

class QuizBuilderScreen extends StatelessWidget {
  const QuizBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Quiz Builder',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      /// ➕ Floating Create Button
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Create Quiz'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => QuizEditorScreen()),
        ),
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
            if (state.quizzes.isEmpty) {
              return const Center(
                child: Text(
                  'No quizzes created yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.quizzes.length,
              itemBuilder: (context, i) {
                final Quiz q = state.quizzes[i];

                return _QuizCard(
                  quiz: q,
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizEditorScreen(existingQuiz: q),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onEdit;

  const _QuizCard({
    required this.quiz,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              /// Left Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.quiz, color: Colors.blue),
              ),

              const SizedBox(width: 16),

              /// Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (quiz.description != null &&
                        quiz.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          quiz.description!,
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

              /// Edit Icon
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
