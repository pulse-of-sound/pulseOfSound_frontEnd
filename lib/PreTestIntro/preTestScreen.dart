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
      correctAnswer: index % 4,
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
      body: Stack(
        children: [
          // الخلفية
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
                  // المربع العلوي: السؤال + الصورة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "السؤال ${currentQuestion + 1} من ${questions.length}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "ما هو الشكل الذي يُكمل المجموعة؟",
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

                  // خيارات الإجابة (موزعين على 2 × 2)
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
                        // ألوان مبهجة متغيرة
                        final borderColors = [
                          Colors.pinkAccent,
                          Colors.lightBlueAccent,
                          Colors.amber,
                          Colors.greenAccent,
                        ];

                        return GestureDetector(
                          onTap: () => _answerQuestion(i),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: borderColors[i % borderColors.length],
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
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
