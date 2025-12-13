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
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Take Quiz',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<QuizTakeCubit, dynamic>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
            cubit.clearError();
          }

          if (state.success == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SuccessScreen()),
            );
          }
        },
        builder: (context, state) {
          if (state.loading == true) {
            return const Center(child: CircularProgressIndicator());
          }

          final Quiz? quiz = state.quiz;
          if (quiz == null) {
            return const Center(child: Text('Quiz not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// Quiz Header
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (quiz.description != null &&
                          quiz.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            quiz.description!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Questions
              ...quiz.questions.map((q) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.questionText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        /// Short Text
                        if (q.answerType == 'ShortText')
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Your answer',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (v) =>
                                cubit.setAnswer(q.id!, v),
                          ),

                        /// MCQ
                        if (q.answerType == 'MCQ')
                          Column(
                            children: List.generate(q.options.length, (i) {
                              final optText = q.options[i];
                              return RadioListTile<int>(
                                value: i,
                                groupValue: state.answers[q.id],
                                title: Text(optText),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onChanged: (v) =>
                                    cubit.setAnswer(q.id!, v),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 12),

              /// Submit Button
              state.submitting == true
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: cubit.submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Submit Quiz',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 10),

              /// Admin Link
              TextButton.icon(
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Admin: View Responses'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ResponseViewerScreen(quizId: quiz.id!),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
