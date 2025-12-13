import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';

class ResponsesState {
  final List<Map<String, dynamic>> responses;
  final bool loading;
  final String? error;

  ResponsesState({List<Map<String, dynamic>>? responses, this.loading = false, this.error})
      : responses = responses ?? [];

  ResponsesState copyWith({List<Map<String, dynamic>>? responses, bool? loading, String? error}) {
    return ResponsesState(
      responses: responses ?? this.responses,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class ResponsesCubit extends Cubit<ResponsesState> {
  final ApiService api;
  ResponsesCubit({required this.api}) : super(ResponsesState());

  Future<void> load(String quizId) async {
    emit(state.copyWith(loading: true));
    try {
      final r = await api.fetchResponses(quizId);
      final list = (r as List<dynamic>).map((e) => Map<String, dynamic>.from(e)).toList();
      emit(state.copyWith(loading: false, responses: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
