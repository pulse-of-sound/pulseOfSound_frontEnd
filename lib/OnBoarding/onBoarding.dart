import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Colors/colors.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  bool _isChecked = false;

  Future<void> _acceptAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("hasAccepted", true);
    Navigator.pushReplacementNamed(context, "/Profile");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.babyPink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                " مرحباً بك في Pulse of Sound ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: const Text(
                      """مرحباً بك في تطبيق **Pulse of Sound** 

تم تطوير هذا التطبيق خصيصاً لمساعدة الأطفال ضعيفي السمع على تطوير مهاراتهم اللغوية والإدراكية من خلال رحلة تعليمية ممتعة مقسّمة إلى ثلاثة مستويات
"نبض الصوت" هو الحل الذي سيكون بحق "النبض الأول"
لقد تبنّينا هذا التحدي الأكبر في حياة هذه الفئة، وصغناه بتطبيق يفتح أمام الطفل عالماً أكثر إشراقاً واندماجاً عالم مليء بالأصوات الجديدة، والحروف الملوّنة، والتجارب الغنية

يوفّر التطبيق فضاءً تعليمياً وتفاعلياً يمكّن الطفل بثقة وتدرّج من تنمية قدراته، ويمنحه الأمل والدعم في كل مرحلة من رحلته

عالم صغير يرافق الطفل عبر أنشطة يومية مشوّقة واختبارات دقيقة ومتابعة مستمرة من الأهل والأخصائيين، واستشارات مباشرة مع الأطباء

من خلال "نبض الصوت" نقدّم منظومة متكاملة للتعلّم، التقييم، والدعم، لنمنح الطفل فرصته الحقيقية في الانطلاق بثقة وأمل.
  
---

 **مميزات إضافية داخل التطبيق:**  
- إمكانية حجز استشارة مع دكتور مختص.  
- التواصل مع أخصائي لمتابعة تطور الطفل.  
- توفير محادثة خاصة للأهل لتبادل الخبرات.  
- تمكين الأهل من متابعة التقييمات والاختبارات الخاصة بالطفل بشكل مباشر.  

---

 هدفنا الاساسي  
أن يصل الطفل لاستخدام أفضل لقدراته الادراكية والبصرية واللغوية، ليكون قادراً على التواصل بثقة والتفاعل مع من حوله .
""",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) =>
                        setState(() => _isChecked = value ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      "أوافق على الشروط والمتابعة",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isChecked ? _acceptAndContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pink,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "متابعة",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
