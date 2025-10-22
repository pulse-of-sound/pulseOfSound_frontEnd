import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Booking/screens/Wallet Screen.dart';
import '../Booking/screens/bookings_list_screen.dart';
import '../Booking/utils/bookings_prefs.dart';
import '../Colors/colors.dart';
import '../LoginScreens/loginscreen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  int pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    final count = await BookingsPrefs.pendingCount();
    setState(() => pendingCount = count);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
            decoration: BoxDecoration(color: AppColors.pink),
          ),
          ListTile(
            leading: const Icon(Icons.wallet),
            title: const Text("المحفظة"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WalletScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("الحجوزات"),
                if (pendingCount > 0)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      "$pendingCount",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingsListScreen()),
              ).then((_) => _loadPendingCount());
            },
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
