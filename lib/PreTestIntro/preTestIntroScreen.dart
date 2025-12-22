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
                  // النص داخل حاوية شفافة لزيادة الوضوح والتناسق
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      "مرحباً بك!\n\n"
                      "قبل أن تبدأ رحلتك التعليمية في تطبيق Pulse of Sound، "
                      "ينبغي عليك إجراء اختبار تمهيدي يتألف من 15 سؤالاً.\n\n"
                      "يجب أن تحصل على 8 إجابات صحيحة على الأقل لتتمكن من متابعة التعلم.\n\n"
                      "إذا حصلت على أقل من ذلك، يمكنك إعادة الاختبار أو الدخول إلى وضع التدريب "
                      "للتدرّب على هذه الأسئلة قبل المتابعة.",
                      style: TextStyle(
                        fontSize: 19,
                        height: 1.6,
                        color: Color(0xFF1A237E), // 🔥 لون نيلي عميق متناسق مع الثيم
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
