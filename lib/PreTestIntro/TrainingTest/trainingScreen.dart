import 'package:flutter/material.dart';
import 'package:pulse_of_sound/PreTestIntro/preTestScreen.dart';
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

  // Dummy data    الباك
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
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => PreTestIntroScreen()));
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
      appBar: AppBar(
        title: Text(
            "التدريب ${currentQuestion + 1} / ${trainingQuestions.length}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "اختر الشكل الصحيح الذي يُكمل المجموعة:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // صورة السؤال
            Image.asset(q.questionImage, height: 200),
            const SizedBox(height: 20),

            // الخيارات
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: q.options.length,
                itemBuilder: (context, i) {
                  Color borderColor = Colors.transparent;

                  if (answered) {
                    if (i == q.correctAnswer) {
                      borderColor = Colors.green;
                    } else if (i == selectedAnswer) {
                      borderColor = Colors.red;
                    }
                  }

                  return GestureDetector(
                    onTap: () => _selectAnswer(i),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: borderColor, width: 3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(q.options[i]),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // زر التالي
            if (answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  currentQuestion < trainingQuestions.length - 1
                      ? "التالي"
                      : "إنهاء التدريب",
                ),
              ),
          ],
        ),
      ),
    );
  }
}
