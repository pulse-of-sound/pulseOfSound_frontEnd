import 'package:flutter/material.dart';
import 'modelQuestion.dart';
import 'resultScreen.dart';

class Pretestscreen extends StatefulWidget {
  const Pretestscreen({super.key});

  @override
  State<Pretestscreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<Pretestscreen> {
  int currentQuestion = 0;
  int score = 0;

  // 15 سؤال (صور افتراضية،  لاحقاً)
  final List<Question> questions = List.generate(
    15,
    (index) => Question(
      questionImage: "images/q${index + 1}.jpg",
      options: [
        "images/q${index + 1}_opt1.jpg",
        "images/q${index + 1}_opt2.jpg",
        "images/q${index + 1}_opt3.jpg",
        "images/q${index + 1}_opt4.jpg",
      ],
      correctAnswer: index % 4, // الجواب الصح للتجربة
    ),
  );

  void _answerQuestion(int selectedIndex) {
    if (selectedIndex == questions[currentQuestion].correctAnswer) {
      score++;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(score: score, total: questions.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQuestion];
    return Scaffold(
      appBar: AppBar(
        title: Text("السؤال ${currentQuestion + 1} من ${questions.length}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "ما هو الشكل الذي يُكمل المجموعة؟",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Image.asset(q.questionImage, height: 200),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: q.options.length,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () => _answerQuestion(i),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
