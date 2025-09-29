import 'package:flutter/material.dart';
import '../Colors/colors.dart';
import 'preTestScreen.dart';

class PreTestIntroScreen extends StatelessWidget {
  const PreTestIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.babyBlue,
      appBar: AppBar(
        title: const Text("الاختبار التمهيدي"),
        backgroundColor: AppColors.babyPink,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "مرحباً بك!\n\n"
              "قبل أن تبدأ رحلتك التعليمية في تطبيق Pulse of Sound، "
              "ينبغي عليك إجراء اختبار تمهيدي يتألف من 15 سؤالاً. "
              "يجب أن تحصل على 8 إجابات صحيحة على الأقل لتتمكن من متابعة التعلم. "
              "إذا حصلت على أقل من ذلك، يمكنك إعادة الاختبار أو الدخول إلى وضع التدريب "
              "للتدرّب على هذه الأسئلة قبل المتابعة.",
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Pretestscreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pink,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "ابدأ الاختبار",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
