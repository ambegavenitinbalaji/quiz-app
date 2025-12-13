import 'question.dart';

class Quiz {
  String? id;
  String title;
  String? description;
  List<Question> questions;

  Quiz({
    this.id,
    required this.title,
    this.description,
    List<Question>? questions,
  }) : questions = questions ?? [];

  factory Quiz.fromJson(Map<String, dynamic> j) => Quiz(
    id: j['_id']?.toString(),
    title: j['title'] ?? '',
    description: j['description'],
    questions: (j['questions'] as List<dynamic>?)
        ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'title': title,
    'description': description,
    'questions': questions.map((q) => q.toJson()).toList(),
  };
}
