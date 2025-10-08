import 'package:flutter/material.dart';
import '../preTestIntroScreen.dart';
import 'modelTrainingQuestion.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int currentQuestion = 0;
  int? selectedAnswer;
  bool answered = false;

  // Dummy data مؤقت لحد ما يجي من الباك
  final List<TrainingQuestion> trainingQuestions = List.generate(
    10,
    (index) => TrainingQuestion(
      questionImage: "images/q${index + 1}.jpg",
      options: [
        "images/q${index + 1}_opt1.jpg",
        "images/q${index + 1}_opt2.jpg",
        "images/q${index + 1}_opt3.jpg",
        "images/q${index + 1}_opt4.jpg",
      ],
      correctAnswer: index % 4,
    ),
  );

  void _selectAnswer(int index) {
    if (answered) return;
    setState(() {
      selectedAnswer = index;
      answered = true;
    });
  }

  void _nextQuestion() {
    if (currentQuestion < trainingQuestions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        answered = false;
      });
    } else {
      _finishTraining();
    }
  }

  void _finishTraining() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("انتهى التدريب"),
        content: const Text("لقد أنهيت جميع الأسئلة التدريبية "),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PreTestIntroScreen()),
              );
            },
            child: const Text("رجوع"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = trainingQuestions[currentQuestion];

    return Scaffold(
      body: Stack(
        children: [
          //  الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/questionScreen1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // العلوي: السؤال + صورة المجموعة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "التدريب ${currentQuestion + 1} من ${trainingQuestions.length}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "اختر الشكل الصحيح الذي يُكمل المجموعة:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Image.asset(q.questionImage, height: 140),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  //  شبكة الخيارات
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: q.options.length,
                      itemBuilder: (context, i) {
                        // حدود مبهجة
                        final borderColors = [
                          Colors.pinkAccent,
                        ];

                        // إذا جاوب → يلون الصح والغلط
                        Color borderColor =
                            borderColors[i % borderColors.length];
                        if (answered) {
                          if (i == q.correctAnswer) {
                            borderColor = Colors.green;
                          } else if (i == selectedAnswer) {
                            borderColor = Colors.red;
                          }
                        }

                        return GestureDetector(
                          onTap: () => _selectAnswer(i),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: borderColor,
                                width: 4,
                              ),
                              color: Colors.white.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                q.options[i],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ✅ زر التالي يظهر بعد الجواب
                  if (answered)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          currentQuestion < trainingQuestions.length - 1
                              ? "التالي"
                              : "إنهاء التدريب",
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
