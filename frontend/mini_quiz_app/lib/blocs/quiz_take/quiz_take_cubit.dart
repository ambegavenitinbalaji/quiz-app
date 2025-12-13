import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/quiz.dart';
import '../../services/api_service.dart';

class QuizTakeState {
  final Quiz? quiz;
  final Map<String, dynamic> answers;
  final bool loading;
  final bool submitting;
  final String? error;
  final bool success;

  QuizTakeState({
    this.quiz,
    Map<String, dynamic>? answers,
    this.loading = false,
    this.submitting = false,
    this.error,
    this.success = false,
  }) : answers = answers ?? {};

  QuizTakeState copyWith({Quiz? quiz, Map<String, dynamic>? answers, bool? loading, bool? submitting, String? error, bool? success}) {
    return QuizTakeState(
      quiz: quiz ?? this.quiz,
      answers: answers ?? this.answers,
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      error: error,
      success: success ?? this.success,
    );
  }
}

class QuizTakeCubit extends Cubit<QuizTakeState> {
  final ApiService api;
  QuizTakeCubit({required this.api}) : super(QuizTakeState());

  Future<void> loadQuiz(String id) async {
    emit(state.copyWith(loading: true));
    try {
      final q = await api.getQuiz(id);
      emit(state.copyWith(quiz: q, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void setAnswer(String questionId, dynamic value) {
    final newAnswers = Map<String, dynamic>.from(state.answers);
    newAnswers[questionId] = value;
    emit(state.copyWith(answers: newAnswers));
  }

  Future<void> submit({String participantName = 'Anonymous'}) async {
    final quiz = state.quiz;
    if (quiz == null) {
      emit(state.copyWith(error: 'No quiz loaded'));
      return;
    }

    // validate required
    for (final q in quiz.questions) {
      if (q.required) {
        final ans = state.answers[q.id];
        if (ans == null || (ans is String && ans.trim().isEmpty)) {
          emit(state.copyWith(error: 'Please answer: ${q.questionText}'));
          return;
        }
      }
    }

    final payload = {
      'participantName': participantName,
      'answers': quiz.questions.map((q) {
        final ans = state.answers[q.id];
        return {'questionId': q.id, 'answer': ans};
      }).toList(),
    };

    emit(state.copyWith(submitting: true, error: null));
    try {
      await api.submitResponse(quiz.id!, payload);
      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
}
