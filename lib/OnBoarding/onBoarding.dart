import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Profile/profile.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "   أهلاً بك! في تطبيق نبض الصوت",
      "subtitle":
          "تم تطوير هذا التطبيق خصيصاً لمساعدة الأطفال ضعيفي السمع على تطوير مهاراتهم اللغوية والإدراكية",
    },
    {
      "title": " التعلم باللعب",
      "subtitle":
          " عالم صغير يرافق الطفل عبر أنشطة يومية مشوّقة واختبارات دقيقة ومتابعة مستمرة من الأهل "
    },
    {
      "title": " دعم الأطباء",
      "subtitle": "يمكنك حجز استشارات مع الأطباء والأخصائيين بسهولة.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/onboarding.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // المحتوى
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, bottom: 160), //  مكان النص
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        page["title"]!,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 6,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page["subtitle"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          height: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 5,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // نقاط التنقل + زر
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 20 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.pinkAccent
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileScreen()),
                      );
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? "لنبدأ " : "التالي ",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
