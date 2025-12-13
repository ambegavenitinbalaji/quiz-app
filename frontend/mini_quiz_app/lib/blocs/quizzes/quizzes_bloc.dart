import 'package:flutter_bloc/flutter_bloc.dart';
import 'quizzes_event.dart';
import 'quizzes_state.dart';
import '../../services/api_service.dart';

class QuizzesBloc extends Bloc<QuizzesEvent, QuizzesState> {
  final ApiService api;
  QuizzesBloc({required this.api}) : super(QuizzesInitial()) {
    on<LoadQuizzesEvent>((e, emit) async {
      emit(QuizzesLoading());
      try {
        final quizzes = await api.fetchQuizzes();
        emit(QuizzesLoaded(quizzes));
      } catch (err, stack) {
      print("🔥 ERROR IN QuizzesBloc → LoadQuizzesEvent");
      print(err);
      print(stack);
      emit(QuizzesError(err.toString()));
    }

  });

    on<RefreshQuizzesEvent>((e, emit) async {
      try {
        final quizzes = await api.fetchQuizzes();
        emit(QuizzesLoaded(quizzes));
      } catch (err, stack) {
        print("🔥 ERROR IN QuizzesBloc → RefreshQuizzesEvent");
        print(err);
        print(stack);
        emit(QuizzesError(err.toString()));
      }
    });
  }
}
