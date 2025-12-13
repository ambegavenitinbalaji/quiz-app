class Question {
  String? id;
  String questionText;
  String answerType; // 'MCQ' or 'ShortText'
  List<String> options;
  bool required;

  Question({
    this.id,
    required this.questionText,
    required this.answerType,
    List<String>? options,
    this.required = false,
  }) : options = options ?? [];

  factory Question.fromJson(Map<String, dynamic> j) {
    final opts = (j['options'] as List<dynamic>?)?.map((o) {
      if (o is Map && o.containsKey('text')) return o['text'] as String;
      return o.toString();
    }).toList();
    return Question(
      id: j['_id']?.toString(),
      questionText: j['questionText'] ?? '',
      answerType: j['answerType'] ?? 'ShortText',
      options: opts ?? [],
      required: j['required'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'questionText': questionText,
    'answerType': answerType,
    if (answerType == 'MCQ') 'options': options.map((t) => {'text': t}).toList(),
    'required': required,
  };
}
