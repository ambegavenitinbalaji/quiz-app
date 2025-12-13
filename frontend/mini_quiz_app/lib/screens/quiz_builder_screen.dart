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
      appBar: AppBar(title: const Text('Quiz Builder')),
      body: BlocBuilder<QuizzesBloc, QuizzesState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create New Quiz'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizEditorScreen())),
              ),
              const SizedBox(height: 16),
              if (state is QuizzesLoading) const CircularProgressIndicator(),
              if (state is QuizzesLoaded)
                Expanded(
                  child: ListView.builder(
                    itemCount: state.quizzes.length,
                    itemBuilder: (context, i) {
                      final q = state.quizzes[i];
                      return ListTile(
                        title: Text(q.title),
                        subtitle: Text(q.description ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => QuizEditorScreen(existingQuiz: q)));
                          },
                        ),
                      );
                    },
                  ),
                ),
              if (state is QuizzesError) Text('Error: ${state.message}'),
            ]),
          );
        },
      ),
    );
  }
}
