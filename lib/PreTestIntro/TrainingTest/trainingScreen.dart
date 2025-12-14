import 'package:flutter/material.dart';
import '../preTestIntroScreen.dart';
import 'modelTrainingQuestion.dart';
import '../../api/training_question_api.dart';
import '../../utils/shared_pref_helper.dart';

class TrainingScreen extends StatefulWidget {
  final String? firstQuestionId;

  const TrainingScreen({super.key, this.firstQuestionId});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int? selectedAnswer;
  bool answered = false;
  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? currentQuestion;
  String? currentQuestionId;
  int questionsAnswered = 0;

  @override
  void initState() {
    super.initState();
    _loadFirstQuestion();
  }

  Future<void> _loadFirstQuestion() async {
    try {
      final token = SharedPrefsHelper.getToken();
      if (token == null) {
        setState(() {
          errorMessage = "لم يتم العثور على جلسة المستخدم";
          isLoading = false;
        });
        return;
      }

      final response = await TrainingQuestionAPI.getNextTrainingQuestion(
        sessionToken: token,
        questionId: "",
        selectedOption: "",
      );

      if (!mounted) return;

      if (response.containsKey('error')) {
        setState(() {
          errorMessage = response['error'];
          isLoading = false;
        });
        return;
      }

      setState(() {
        currentQuestion = response;
        currentQuestionId = response['question_id'];
        selectedAnswer = null;
        answered = false;
        isLoading = false;
        print("DEBUG _loadFirstQuestion - Set currentQuestion: $response");
      });
    } catch (e) {
      print("Error loading first question: $e");
      if (mounted) {
        setState(() {
          errorMessage = "خطأ في تحميل السؤال: $e";
          isLoading = false;
        });
      }
    }
  }

  void _selectAnswer(int index) {
    // OLD: if (answered) return; -> Removed to allow changing answer
    setState(() {
      selectedAnswer = index;
      answered = true;
    });
  }

  Future<void> _nextQuestion() async {
    try {
      final token = SharedPrefsHelper.getToken();
      if (token == null) return;

      final optionLetters = ['A', 'B', 'C'];
      final selectedOption = optionLetters[selectedAnswer ?? 0];

      final response = await TrainingQuestionAPI.getNextTrainingQuestion(
        sessionToken: token,
        questionId: currentQuestionId ?? "",
        selectedOption: selectedOption,
      );

      if (!mounted) return;

      if (response.containsKey('error')) {
        _finishTraining();
        return;
      }

      if (response.containsKey('message') && response['message'].contains('أجبت على')) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("انتهى التدريب"),
            content: Text(response['message']),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PreTestIntroScreen()),
                  );
                },
                child: const Text("العودة"),
              )
            ],
          ),
        );
        return;
      }

      setState(() {
        currentQuestion = response;
        currentQuestionId = response['question_id'];
        questionsAnswered++;
        selectedAnswer = null;
        answered = false;
        print("DEBUG _nextQuestion - Set currentQuestion: $response");
      });
    } catch (e) {
      print("Error getting next question: $e");
      _finishTraining();
    }
  }

  void _finishTraining() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("انتهى التدريب"),
        content: Text("لقد أجبت على $questionsAnswered أسئلة تدريبية"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PreTestIntroScreen()),
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
                  _loadFirstQuestion();
                },
                child: const Text("إعادة المحاولة"),
              ),
            ],
          ),
        ),
      );
    }

    if (currentQuestion == null) {
      return const Scaffold(
        body: Center(
          child: Text("لم تتم تحميل السؤال"),
        ),
      );
    }

    final questionImageUrl = currentQuestion!['question_image_url'] as String?;
    final options = currentQuestion!['options'] as Map<String, dynamic>? ?? {};
    final optionLetters = ['A', 'B', 'C'];
    
    print("DEBUG Training - Question ID: ${currentQuestion!['question_id']}");
    print("DEBUG Training - Question Image URL: $questionImageUrl");
    print("DEBUG Training - Options Map: $options");
    print("DEBUG Training - Option Letters: $optionLetters");
    
    for (int i = 0; i < optionLetters.length; i++) {
      final url = options[optionLetters[i]] as String?;
      print("DEBUG Training - Option $i (${optionLetters[i]}): $url");
    }

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
                          "التدريب ${questionsAnswered + 1}",
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
                        questionImageUrl != null && questionImageUrl.isNotEmpty
                            ? Image.network(
                                questionImageUrl,
                                height: 140,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
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
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              )
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
                      itemCount: 3,
                      itemBuilder: (context, i) {
                        final borderColors = [
                          Colors.pinkAccent,
                          Colors.lightBlueAccent,
                          Colors.amber,
                        ];

                        final optionUrl = options[optionLetters[i]] as String?;
                        final isSelected = selectedAnswer == i;
                        
                        print("DEBUG GridView - Item $i (${optionLetters[i]}): URL=$optionUrl, isSelected=$isSelected");

                        return GestureDetector(
                          onTap: () => _selectAnswer(i),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.green
                                    : borderColors[i % borderColors.length],
                                width: isSelected ? 5 : 4,
                              ),
                              color: isSelected
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.white.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: optionUrl != null && optionUrl.isNotEmpty
                                  ? Image.network(
                                      optionUrl,
                                      fit: BoxFit.contain,
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
                                        print("Training Image Error for Option ${optionLetters[i]}: $error");
                                        print("Training Image Stack: $stackTrace");
                                        return const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error,
                                                  size: 40, color: Colors.red),
                                              SizedBox(height: 4),
                                              Text(
                                                'Failed',
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Icon(Icons.image,
                                          size: 40, color: Colors.grey),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

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
                        child: const Text("التالي"),
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
