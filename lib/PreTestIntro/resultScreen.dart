import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Articles/articlesScreen.dart';
import 'package:pulse_of_sound/HomeScreens/HomeScreen.dart';
import 'package:pulse_of_sound/PreTestIntro/TrainingTest/trainingScreen.dart';
import 'package:pulse_of_sound/PreTestIntro/preTestScreen.dart';

import '../HomeScreens/bottomNavBar.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    bool passed = score >= 8;
    double percentage = (score / total);

    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/result.jpg"),
                fit: BoxFit.fill,
              ),
            ),
          ),

          // المحتوى
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: ClipOval(
                      child: Image.asset(
                        passed
                            ? "images/resultSuccess1.jpg"
                            : "images/resultFaild1.jpg",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // رسالة
                  Text(
                    passed ? "أحسنت  لقد اجتزت الاختبار" : "للأسف  لم تنجح",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: passed ? Colors.pinkAccent : Colors.redAccent,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // النتيجة
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Card(
                      color: Colors.white.withOpacity(0.9),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "النتيجة: $score من $total",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: percentage,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(8),
                              backgroundColor: Colors.grey[300],
                              color: passed ? Colors.pinkAccent : Colors.red,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${(percentage * 100).toStringAsFixed(1)}%",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // الأزرار
                  if (passed)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const BottomNavScreen(initialIndex: 2)),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "الانتقال إلى الرئيسية",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const Pretestscreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text("إعادة الاختبار",
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TrainingScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text("التدريب على الأسئلة",
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
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
