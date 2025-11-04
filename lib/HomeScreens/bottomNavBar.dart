import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pulse_of_sound/Articles/articlesScreen.dart';
import 'package:pulse_of_sound/HomeScreens/HomeScreen.dart';
import '../Booking/screens/consultation_flow.dart';
import '../Colors/colors.dart';
import '../Levels/StageDetailScreen.dart';
import '../Levels/levelsScreen.dart';
import '../Parent/screens/ParentChatHome.dart';

class BottomNavScreen extends StatefulWidget {
  final int initialIndex;
  const BottomNavScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    LevelScreen(),
    ConsultationTypeScreen(),
    HomeScreen(),
    ParentChatHome(),
    const ArticlesScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: _pages[_selectedIndex],

      // 🔹 الزر الدائري بالنص
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.skyBlue, AppColors.babyPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => _onItemTapped(2),
          child: const Icon(Iconsax.home_2, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🔹 البار السفلي
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 15,
        color: Colors.white.withOpacity(0.85), // 🔸 مش أبيض ناصع
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 28.0), // 🔹 توازن المسافات
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الجهة اليسار
              Row(
                children: [
                  _buildNavItem(Iconsax.game, 0),
                  const SizedBox(width: 28),
                  _buildNavItem(Icons.local_hospital, 1),
                ],
              ),

              // الجهة اليمين
              Row(
                children: [
                  _buildNavItem(Iconsax.message, 3),
                  const SizedBox(width: 28),
                  _buildNavItem(Iconsax.document, 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔸 بناء كل عنصر أيقونة بالـ BottomNav
  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: 45, // 🔹 حجم متساوٍ لكل عنصر
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.skyBlue : Colors.grey.shade600,
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3,
              width: 18,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.skyBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
