import 'package:flutter/material.dart';
import 'bottomNavBar.dart';
import 'drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: DrawerScreen(),
      body: BottomNavScreen(),
    );
  }
}
