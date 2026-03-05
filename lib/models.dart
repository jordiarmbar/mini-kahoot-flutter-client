class Question {
  final String id;
  final String questionText;
  final List<String> answers;
  final List<int> correctAnswers;
  final int timeLimit;

  Question({
    required this.id,
    required this.questionText,
    required this.answers,
    required this.correctAnswers,
    this.timeLimit = 30,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'answers': answers,
      'correctAnswers': correctAnswers,
      'timeLimit': timeLimit,
    };
  }

  factory Question.fromMap(String id, Map<String, dynamic> map) {
    return Question(
      id: id,
      questionText: map['questionText'] ?? '',
      answers: List<String>.from(map['answers'] ?? []),
      correctAnswers: List<int>.from(map['correctAnswers'] ?? []),
      timeLimit: (map['timeLimit'] as int?) ?? 30,
    );
  }
}
