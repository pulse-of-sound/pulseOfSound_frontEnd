class Question {
  final String? id;
  final String questionImage;
  final List<String> options;
  final int correctAnswer;

  Question({
    this.id,
    required this.questionImage,
    required this.options,
    required this.correctAnswer,
  });
}
