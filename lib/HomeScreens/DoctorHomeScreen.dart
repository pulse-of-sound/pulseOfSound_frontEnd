import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Doctor/Screens/doctor_profile_screen.dart';
import '../../Colors/colors.dart';
import '../Doctor/Screens/doctor_articles_screen.dart';
import '../Doctor/Screens/doctor_bookings_screen.dart';
import '../Doctor/Screens/doctor_chat_screen.dart';
import '../Doctor/Screens/doctor_reports_screen.dart';
import '../Doctor/Screens/doctor_wallet_screen.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cards = [
      {
        "title": "الملف الشخصي",
        "icon": Icons.person,
        "screen": const DoctorProfileScreen()
      },
      {
        "title": "الاستشارات",
        "icon": Icons.calendar_month,
        "screen": const DoctorBookingsScreen()
      },
      {
        "title": "المحفظة",
        "icon": Icons.account_balance_wallet,
        "screen": const DoctorWalletScreen()
      },
      {
        "title": "المحادثات",
        "icon": Icons.chat,
        "screen": const DoctorChatMainScreen()
      },
      {
        "title": "المقالات",
        "icon": Icons.article,
        "screen": const DoctorArticlesScreen()
      },
      {
        "title": "التقارير الطبية",
        "icon": Icons.file_copy,
        "screen": const DoctorReportsScreen(
          parentId: '',
          parentName: '',
        )
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/doctorsBackground.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "لوحة تحكم الطبيب",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: cards.length,
                      itemBuilder: (context, i) {
                        final card = cards[i];
                        return InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => card["screen"]),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 8)
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(card["icon"],
                                    size: 45, color: AppColors.skyBlue),
                                const SizedBox(height: 10),
                                Text(card["title"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                          ),
                        );
                      },
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
