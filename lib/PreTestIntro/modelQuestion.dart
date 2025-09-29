class Question {
  final String questionImage; // صورة المجموعة الناقصة
  final List<String> options; // صور الخيارات
  final int correctAnswer; // رقم الخيار الصحيح 4,1,2,3)

  Question({
    required this.questionImage,
    required this.options,
    required this.correctAnswer,
  });
}
