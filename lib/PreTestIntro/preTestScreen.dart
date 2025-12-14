import 'package:flutter/material.dart';
import 'modelQuestion.dart';
import 'resultScreen.dart';
import '../api/placement_test_api.dart';
import '../utils/shared_pref_helper.dart';

class Pretestscreen extends StatefulWidget {
  const Pretestscreen({super.key});

  @override
  State<Pretestscreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<Pretestscreen> {
  int currentQuestion = 0;
  List<Question> questions = [];
  bool isLoading = true;
  String? errorMessage;
  List<int> userAnswers = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final token = SharedPrefsHelper.getToken();
      if (token == null) {
        setState(() {
          errorMessage = "لم يتم العثور على جلسة المستخدم";
          isLoading = false;
        });
        return;
      }

      final response = await PlacementTestAPI.getPlacementTestQuestions(
        sessionToken: token,
      );

      if (response.isNotEmpty) {
        setState(() {
          questions = response.map((q) {
            final options = q['options'] as Map<String, dynamic>? ?? {};
            final optionsList = [
              options['A'] as String? ?? "",
              options['B'] as String? ?? "",
              options['C'] as String? ?? "",
              options['D'] as String? ?? "",
            ];

            print("DEBUG: Question ID: ${q['id']}");
            print("DEBUG: Question Image: ${q['question_image_url']}");
            print("DEBUG: Options: $optionsList");

            return Question(
              id: q['id'] as String?,
              questionImage:
                  q['question_image_url'] as String? ?? "images/q1.jpg",
              options: optionsList,
              correctAnswer: 0,
            );
          }).toList();
          userAnswers = List.filled(questions.length, -1);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "فشل تحميل الأسئلة";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "خطأ: $e";
        isLoading = false;
      });
    }
  }

  void _answerQuestion(int selectedIndex) {
    userAnswers[currentQuestion] = selectedIndex;

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      _submitAnswers();
    }
  }

  Future<void> _submitAnswers() async {
    try {
      final token = SharedPrefsHelper.getToken();
      if (token == null) return;

      final answers = <Map<String, String>>[];
      final optionLetters = ['A', 'B', 'C', 'D'];

      for (int i = 0; i < questions.length; i++) {
        if (questions[i].id != null && userAnswers[i] >= 0) {
          answers.add({
            'questionId': questions[i].id!,
            'selectedOption': optionLetters[userAnswers[i]],
          });
        }
      }

      print("📤 Submitting ${answers.length} answers to backend");
      for (var ans in answers) {
        print("  - Question ${ans['questionId']}: ${ans['selectedOption']}");
      }

      final result = await PlacementTestAPI.submitPlacementTestAnswers(
        sessionToken: token,
        answers: answers,
      );

      print("✅ Backend response: $result");

      if (!mounted) return;

      final correctCount = (result['correctCount'] as num?)?.toInt() ?? 0;
      print("📊 Correct answers: $correctCount / ${questions.length}");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ResultScreen(score: correctCount, total: questions.length),
        ),
      );
    } catch (e) {
      print("Error submitting answers: $e");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(score: 0, total: questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _fetchQuestions();
                },
                child: const Text("إعادة المحاولة"),
              ),
            ],
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("لا توجد أسئلة"),
        ),
      );
    }

    final q = questions[currentQuestion];

    return Scaffold(
      body: Stack(
        children: [
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
                        q.questionImage.isNotEmpty
                            ? (q.questionImage.startsWith('http')
                                ? Image.network(
                                    q.questionImage,
                                    height: 140,
                                    fit: BoxFit.contain,
                                    headers: const {
                                      'X-Parse-Application-Id':
                                          'cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7',
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print(" Question Image Error: $error");
                                      print("URL: ${q.questionImage}");
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error,
                                                color: Colors.red),
                                            SizedBox(height: 4),
                                            Text('Error',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(q.questionImage, height: 140))
                            : Container(
                                height: 140,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
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
                              child: q.options[i].isEmpty
                                  ? const Center(
                                      child: Icon(Icons.image,
                                          size: 40, color: Colors.grey))
                                  : (q.options[i].startsWith('http')
                                      ? GestureDetector(
                                          onTap: () => _answerQuestion(i),
                                          child: Image.network(
                                            q.options[i],
                                            fit: BoxFit.contain,
                                            headers: const {
                                              'X-Parse-Application-Id':
                                                  'cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7',
                                            },
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  " Option Image Error: $error");
                                              print("Option Index: $i");
                                              print("URL: ${q.options[i]}");
                                              return const Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.error,
                                                        size: 40,
                                                        color: Colors.red),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Error',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.red),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () => _answerQuestion(i),
                                          child: Image.asset(
                                            q.options[i],
                                            fit: BoxFit.contain,
                                          ),
                                        )),
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
