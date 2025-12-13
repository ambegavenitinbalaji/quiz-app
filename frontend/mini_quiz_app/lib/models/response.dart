class Answer {
  final String questionId;
  final dynamic answer;
  Answer({required this.questionId, required this.answer});

  Map<String, dynamic> toJson() => {'questionId': questionId, 'answer': answer};
}

class QuizResponse {
  final String id;
  final String? participantName;
  final DateTime submittedAt;
  final List<Map<String, dynamic>> answers;
  QuizResponse({
    required this.id,
    this.participantName,
    required this.submittedAt,
    required this.answers,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> j) {
    return QuizResponse(
      id: j['_id'] ?? '',
      participantName: j['participantName'],
      submittedAt: DateTime.tryParse(j['submittedAt']?.toString() ?? '') ?? DateTime.now(),
      answers: (j['answers'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
    );
  }
}
