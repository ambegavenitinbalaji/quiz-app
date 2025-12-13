import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';
import '../blocs/quiz_take/quiz_take_cubit.dart';
import '../models/quiz.dart';
import 'success_screen.dart';
import 'response_viewer_screen.dart';

class QuizTakingScreen extends StatelessWidget {
  final String quizId;
  const QuizTakingScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return BlocProvider(
      create: (_) => QuizTakeCubit(api: api)..loadQuiz(quizId),
      child: const _QuizTakingView(),
    );
  }
}

class _QuizTakingView extends StatelessWidget {
  const _QuizTakingView({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuizTakeCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Take Quiz')),
      body: BlocConsumer<QuizTakeCubit, dynamic>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
            cubit.clearError();
          }
          if (state.success == true) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SuccessScreen()));
          }
        },
        builder: (context, state) {
          if (state.loading == true) return const Center(child: CircularProgressIndicator());
          final Quiz? quiz = state.quiz;
          if (quiz == null) return const Center(child: Text('Quiz not found'));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(quiz.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (quiz.description != null) Text(quiz.description!),
                const SizedBox(height: 12),
                ...quiz.questions.map((q) {
                  if (q.answerType == 'ShortText') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: q.questionText, border: const OutlineInputBorder()),
                        onChanged: (v) => cubit.setAnswer(q.id!, v),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.questionText),
                          const SizedBox(height: 6),
                          ...List.generate(q.options.length, (i) {
                            final optText = q.options[i];
                            return RadioListTile<int>(
                              title: Text(optText),
                              value: i,
                              groupValue: state.answers[q.id],
                              onChanged: (v) => cubit.setAnswer(q.id!, v),
                            );
                          })
                        ],
                      ),
                    );
                  }
                }).toList(),
                const SizedBox(height: 12),
                state.submitting == true ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
                  onPressed: () => cubit.submit(),
                  child: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Submit')),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResponseViewerScreen(quizId: quiz.id!))),
                  child: const Text('Admin: View Responses'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
