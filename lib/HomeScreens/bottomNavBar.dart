import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../Colors/colors.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text("الرئيسية")),
    const Center(child: Text("الألعاب")),
    const Center(child: Text("الاستشارات")),
    const Center(child: Text("المحادثة")),
    const Center(child: Text("الأبحاث")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.skyBlue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.game),
            label: "الألعاب",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.health),
            label: "الاستشارات",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.message),
            label: "المحادثة",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.search_normal),
            label: "الأبحاث",
          ),
        ],
      ),
    );
  }
}
