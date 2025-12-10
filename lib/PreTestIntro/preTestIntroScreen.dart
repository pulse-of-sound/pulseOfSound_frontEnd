import 'package:flutter/material.dart';
import 'preTestScreen.dart';

class PreTestIntroScreen extends StatelessWidget {
  const PreTestIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/pretestIntro.jpg"), // 🔥 الخلفية
                fit: BoxFit.cover,
              ),
            ),
          ),

          // المحتوى فوق الخلفية
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // النص
                  const Text(
                    "مرحباً بك!\n\n"
                    "قبل أن تبدأ رحلتك التعليمية في تطبيق Pulse of Sound، "
                    "ينبغي عليك إجراء اختبار تمهيدي يتألف من 15 سؤالاً.\n\n"
                    "يجب أن تحصل على 8 إجابات صحيحة على الأقل لتتمكن من متابعة التعلم.\n\n"
                    "إذا حصلت على أقل من ذلك، يمكنك إعادة الاختبار أو الدخول إلى وضع التدريب "
                    "للتدرّب على هذه الأسئلة قبل المتابعة.",
                    style: TextStyle(
                      fontSize: 20, // 🔥 أكبر شوي
                      height: 1.7,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black87, // 🔥 ظل أوضح
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 50),

                  // الزر
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.6, // 🔥 أصغر من العرض الكامل
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const Pretestscreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.pink,
                        elevation: 8,
                      ),
                      child: const Text(
                        " ابدأ الاختبار",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
