import 'package:flutter/material.dart';

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
              passed ? "تهانينا 🎉" : "للأسف 😔",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: passed ? Colors.green : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),

            // النتيجة
            Text(
              "لقد حصلت على $score من $total",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),

            // إذا ناجح → زر للانتقال للهوم
            if (passed)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/Home");
                },
                icon: const Icon(Icons.home),
                label: const Text("الانتقال إلى الصفحة الرئيسية"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              )
            else
              // إذا راسب → خيارين (إعادة أو تدريب)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/Quiz");
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("إعادة الاختبار"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/Training");
                    },
                    icon: const Icon(Icons.school),
                    label: const Text("التدريب على الأسئلة"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
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
