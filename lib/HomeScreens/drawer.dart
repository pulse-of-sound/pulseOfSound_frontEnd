import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Colors/colors.dart';
import '../Profile/profile.dart';
import '../LoginScreens/loginscreen.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // مسح كل البيانات
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("اسم المستخدم"),
            accountEmail: Text("example@email.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.grey),
            ),
            decoration: BoxDecoration(
              color: AppColors.pink,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("الملف الشخصي"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("الإعدادات"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("تسجيل الخروج"),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
