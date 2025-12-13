import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/quizzes/quizzes_bloc.dart';
import '../blocs/quizzes/quizzes_event.dart';
import '../services/api_service.dart';
import '../blocs/quiz_form/quiz_form_cubit.dart';
import '../models/question.dart';
import '../models/quiz.dart';

class QuizEditorScreen extends StatelessWidget {
  final Quiz? existingQuiz;
  const QuizEditorScreen({super.key, this.existingQuiz});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return BlocProvider(
      create: (_) => QuizFormCubit(api: api)..initFromQuiz(existingQuiz),
      child: _QuizEditorView(existingQuiz: existingQuiz),
    );
  }
}

class _QuizEditorView extends StatefulWidget {
  final Quiz? existingQuiz;
  const _QuizEditorView({this.existingQuiz});
  @override
  State<_QuizEditorView> createState() => _QuizEditorViewState();
}

class _QuizEditorViewState extends State<_QuizEditorView> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<QuizFormCubit>();
    if (widget.existingQuiz != null) {
      _titleCtrl.text = widget.existingQuiz!.title;
      _descCtrl.text = widget.existingQuiz!.description ?? '';
      cubit.initFromQuiz(widget.existingQuiz);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuizFormCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingQuiz == null ? 'Create Quiz' : 'Edit Quiz')),
      body: BlocConsumer<QuizFormCubit, dynamic>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
            cubit.clearError();
          }
          if (state.success == true) {
            // notify QuizzesBloc to refresh list
            context.read<QuizzesBloc>().add(RefreshQuizzesEvent());
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final quiz = state.quiz as Quiz;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  onChanged: cubit.updateTitle,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  onChanged: cubit.updateDescription,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      onPressed: cubit.addQuestion,
                    )
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(quiz.questions.length, (idx) {
                  final q = quiz.questions[idx];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        TextField(
                          decoration: const InputDecoration(labelText: 'Question Text'),
                          onChanged: (v) => cubit.updateQuestionAt(idx, Question(id: q.id, questionText: v, answerType: q.answerType, options: q.options, required: q.required)),
                          controller: TextEditingController(text: q.questionText),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Type: '),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: q.answerType,
                              items: const [
                                DropdownMenuItem(value: 'ShortText', child: Text('Short Text')),
                                DropdownMenuItem(value: 'MCQ', child: Text('MCQ')),
                              ],
                              onChanged: (v) {
                                final updated = Question(id: q.id, questionText: q.questionText, answerType: v ?? 'ShortText', options: v == 'MCQ' ? (q.options.isEmpty ? [''] : q.options) : [], required: q.required);
                                cubit.updateQuestionAt(idx, updated);
                              },
                            ),
                            const Spacer(),
                            Checkbox(value: q.required, onChanged: (val) {
                              final updated = Question(id: q.id, questionText: q.questionText, answerType: q.answerType, options: q.options, required: val ?? false);
                              cubit.updateQuestionAt(idx, updated);
                            }),
                            const Text('Required'),
                            IconButton(onPressed: () => cubit.removeQuestionAt(idx), icon: const Icon(Icons.delete, color: Colors.red)),
                          ],
                        ),
                        if (q.answerType == 'MCQ') ...[
                          const SizedBox(height: 8),
                          const Text('Options:'),
                          const SizedBox(height: 8),
                          ...List.generate(q.options.length, (oi) {
                            final val = q.options[oi];
                            return Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(labelText: 'Option ${oi + 1}'),
                                    controller: TextEditingController(text: val),
                                    onChanged: (v) {
                                      final newOptions = List<String>.from(q.options);
                                      newOptions[oi] = v;
                                      cubit.updateQuestionAt(idx, Question(id: q.id, questionText: q.questionText, answerType: q.answerType, options: newOptions, required: q.required));
                                    },
                                  ),
                                ),
                                IconButton(onPressed: () {
                                  final newOptions = List<String>.from(q.options)..removeAt(oi);
                                  cubit.updateQuestionAt(idx, Question(id: q.id, questionText: q.questionText, answerType: q.answerType, options: newOptions, required: q.required));
                                }, icon: const Icon(Icons.delete)),
                              ],
                            );
                          }),
                          TextButton.icon(onPressed: () {
                            final newOptions = List<String>.from(q.options)..add('');
                            cubit.updateQuestionAt(idx, Question(id: q.id, questionText: q.questionText, answerType: q.answerType, options: newOptions, required: q.required));
                          }, icon: const Icon(Icons.add), label: const Text('Add Option'))
                        ],
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                state.saving == true
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: cubit.save,
                  child: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Save Quiz')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
