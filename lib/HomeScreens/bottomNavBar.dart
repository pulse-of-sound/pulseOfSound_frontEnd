import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pulse_of_sound/Articles/articlesScreen.dart';
import 'package:pulse_of_sound/HomeScreens/HomeScreen.dart';
import '../Colors/colors.dart';

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
    const Center(child: Text("الألعاب", style: TextStyle(fontSize: 18))),
    const Center(child: Text("الألعاب", style: TextStyle(fontSize: 18))),
    const Center(child: Text("إضافة", style: TextStyle(fontSize: 18))),
    const ArticlesScreen(),
    const Center(child: Text("المحادثة", style: TextStyle(fontSize: 18))),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: _pages[_selectedIndex],
      floatingActionButton: Container(
        height: 62,
        width: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.skyBlue, AppColors.babyPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => _onItemTapped(2),
          child: const Icon(Iconsax.add, size: 26, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 10,
        color: Colors.white.withOpacity(0.95),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                _buildNavItem(Iconsax.home, 0),
                const SizedBox(width: 5),
                _buildNavItem(Iconsax.game, 1),
              ]),
              Row(children: [
                _buildNavItem(Iconsax.document, 3),
                const SizedBox(width: 5),
                _buildNavItem(Iconsax.message, 4),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return MaterialButton(
      minWidth: 50,
      onPressed: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 23,
              color: isSelected ? AppColors.skyBlue : Colors.grey.shade500),
          const SizedBox(height: 3),
          Container(
            height: 3,
            width: 18,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.skyBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
