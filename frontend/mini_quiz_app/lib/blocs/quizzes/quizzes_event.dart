import 'package:equatable/equatable.dart';

abstract class QuizzesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadQuizzesEvent extends QuizzesEvent {}
class RefreshQuizzesEvent extends QuizzesEvent {}
