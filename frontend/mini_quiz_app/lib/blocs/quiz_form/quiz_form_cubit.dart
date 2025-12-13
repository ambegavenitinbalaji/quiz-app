import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';
import '../../services/api_service.dart';

class QuizFormState {
  final Quiz quiz;
  final bool saving;
  final String? error;
  final bool success;

  QuizFormState({
    required this.quiz,
    this.saving = false,
    this.error,
    this.success = false,
  });

  QuizFormState copyWith({Quiz? quiz, bool? saving, String? error, bool? success}) {
    return QuizFormState(
      quiz: quiz ?? this.quiz,
      saving: saving ?? this.saving,
      error: error,
      success: success ?? this.success,
    );
  }
}

class QuizFormCubit extends Cubit<QuizFormState> {
  final ApiService api;
  QuizFormCubit({required this.api}) : super(QuizFormState(quiz: Quiz(title: '', questions: [])));

  void initFromQuiz(Quiz? quiz) {
    if (quiz != null) emit(state.copyWith(quiz: quiz));
  }

  void updateTitle(String v) => emit(state.copyWith(quiz: Quiz(id: state.quiz.id, title: v, description: state.quiz.description, questions: state.quiz.questions)));

  void updateDescription(String v) => emit(state.copyWith(quiz: Quiz(id: state.quiz.id, title: state.quiz.title, description: v, questions: state.quiz.questions)));

  void addQuestion() {
    final q = Question(questionText: '', answerType: 'ShortText');
    final list = List<Question>.from(state.quiz.questions)..add(q);
    emit(state.copyWith(quiz: Quiz(id: state.quiz.id, title: state.quiz.title, description: state.quiz.description, questions: list)));
  }

  void removeQuestionAt(int idx) {
    final list = List<Question>.from(state.quiz.questions)..removeAt(idx);
    emit(state.copyWith(quiz: Quiz(id: state.quiz.id, title: state.quiz.title, description: state.quiz.description, questions: list)));
  }

  void updateQuestionAt(int idx, Question q) {
    final list = List<Question>.from(state.quiz.questions);
    list[idx] = q;
    emit(state.copyWith(quiz: Quiz(id: state.quiz.id, title: state.quiz.title, description: state.quiz.description, questions: list)));
  }

  Future<void> save() async {
    // validation: title, each question text, MCQ options >=2
    final q = state.quiz;
    if (q.title.trim().isEmpty) {
      emit(state.copyWith(error: 'Title is required'));
      return;
    }
    for (final question in q.questions) {
      if (question.questionText.trim().isEmpty) {
        emit(state.copyWith(error: 'Every question must have text'));
        return;
      }
      if (question.answerType == 'MCQ' && question.options.length < 2) {
        emit(state.copyWith(error: 'MCQ questions must have at least 2 options'));
        return;
      }
    }

    emit(state.copyWith(saving: true, error: null));
    try {
      if (q.id == null) {
        final created = await api.createQuiz(q);
        emit(state.copyWith(saving: false, success: true, quiz: created));
      } else {
        final updated = await api.updateQuiz(q.id!, q.toJson());
        emit(state.copyWith(saving: false, success: true, quiz: updated));
      }
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
}
