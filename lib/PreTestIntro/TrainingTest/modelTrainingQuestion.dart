class TrainingQuestion {
  final String questionImage; // صورة السؤال
  final List<String> options; // صور الخيارات
  final int correctAnswer; // رقم الجواب الصحيح (0 → 3)

  TrainingQuestion({
    required this.questionImage,
    required this.options,
    required this.correctAnswer,
  });
}
