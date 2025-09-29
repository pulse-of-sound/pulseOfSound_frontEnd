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
    const Center(child: Text("إضافة")),
    const Center(child: Text("الاستشارات")),
    const Center(child: Text("المحادثة")),
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

      // الزر الكبير بالنص
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.skyBlue, AppColors.babyPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            setState(() {
              _selectedIndex = 2; // صفحة الإضافة
            });
          },
          child: const Icon(Iconsax.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom App Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الجهة اليسار
              Row(
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => _onItemTapped(0),
                    child: Icon(
                      Iconsax.home,
                      size: 26,
                      color:
                          _selectedIndex == 0 ? AppColors.skyBlue : Colors.grey,
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => _onItemTapped(1),
                    child: Icon(
                      Iconsax.game,
                      size: 26,
                      color:
                          _selectedIndex == 1 ? AppColors.skyBlue : Colors.grey,
                    ),
                  ),
                ],
              ),

              // الجهة اليمين
              Row(
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => _onItemTapped(3),
                    child: Icon(
                      Iconsax.health,
                      size: 26,
                      color:
                          _selectedIndex == 3 ? AppColors.skyBlue : Colors.grey,
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => _onItemTapped(4),
                    child: Icon(
                      Iconsax.message,
                      size: 26,
                      color:
                          _selectedIndex == 4 ? AppColors.skyBlue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
