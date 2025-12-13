import 'package:equatable/equatable.dart';
import '../../models/quiz.dart';

abstract class QuizzesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class QuizzesInitial extends QuizzesState {}
class QuizzesLoading extends QuizzesState {}
class QuizzesLoaded extends QuizzesState {
  final List<Quiz> quizzes;
  QuizzesLoaded(this.quizzes);
  @override
  List<Object?> get props => [quizzes];
}
class QuizzesError extends QuizzesState {
  final String message;
  QuizzesError(this.message);
  @override
  List<Object?> get props => [message];
}
