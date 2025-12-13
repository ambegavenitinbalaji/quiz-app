import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';
import '../blocs/responses/responses_cubit.dart';
import '../blocs/responses/responses_state.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';
import '../models/quiz.dart';

class ResponseViewerScreen extends StatelessWidget {
  final String quizId;
  const ResponseViewerScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return BlocProvider(
      create: (_) => ResponsesCubit(api: api)..load(quizId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Responses')),
        body: BlocBuilder<ResponsesCubit, ResponsesState>(
          builder: (context, state) {
            if (state.loading) return const Center(child: CircularProgressIndicator());
            if (state.error != null) return Center(child: Text('Error: ${state.error}'));
            if (state.responses.isEmpty) return const Center(child: Text('No responses yet.'));
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (ctx, i) {
                final r = state.responses[i];
                final participant = r['participantName'] ?? 'Anonymous';
                final answers = (r['answers'] as List<dynamic>?) ?? [];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('By: $participant', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...answers.map((a) {
                        final qid = a['questionId'] ?? '';
                        final ans = a['answer'] ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text('$qid : $ans'),
                        );
                      }).toList(),
                    ]),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: state.responses.length,
            );
          },
        ),
      ),
    );
  }
}
