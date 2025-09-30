import 'package:flutter/material.dart';
import 'package:pulse_of_sound/HomeScreens/HomeScreen.dart';
import 'package:pulse_of_sound/PreTestIntro/TrainingTest/trainingScreen.dart';
import 'package:pulse_of_sound/PreTestIntro/preTestScreen.dart';

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
      appBar: AppBar(
        title: const Text("نتيجة الاختبار"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة نجاح أو فشل
            Icon(
              passed ? Icons.emoji_events : Icons.error_outline,
              color: passed ? Colors.green : Colors.redAccent,
              size: 100,
            ),
            const SizedBox(height: 20),

            // رسالة النجاح أو الفشل
            Text(
              passed ? "أحسنت  لقد اجتزت الاختبار" : "للأسف لم تنجح ",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: passed ? Colors.green : Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // النتيجة
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "النتيجة: $score من $total",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: percentage,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.grey[300],
                      color: passed ? Colors.green : Colors.redAccent,
                    ),
                    const SizedBox(height: 8),
                    Text("${(percentage * 100).toStringAsFixed(1)}%"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // إذا ناجح → زر للانتقال للهوم
            if (passed)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomeScreen()));
                },
                icon: const Icon(Icons.home),
                label: const Text("الانتقال إلى الصفحة الرئيسية"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              // إذا راسب → خيارين (إعادة أو تدريب)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => Pretestscreen()));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("إعادة الاختبار"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => TrainingScreen()));
                    },
                    icon: const Icon(Icons.school),
                    label: const Text("التدريب على الأسئلة"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
