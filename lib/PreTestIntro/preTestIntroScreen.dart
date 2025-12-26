import 'package:flutter/material.dart';
import 'preTestScreen.dart';

class PreTestIntroScreen extends StatelessWidget {
  const PreTestIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/pretestIntro.jpg"), 
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

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
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
                        color:
                            Color(0xFF4A4A4A), 
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // الزر
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.6, 
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
