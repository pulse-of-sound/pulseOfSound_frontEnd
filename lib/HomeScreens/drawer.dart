import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Booking/screens/WalletScreenUpdated.dart';
import '../Booking/screens/bookings_list_screen.dart';
import '../Booking/utils/bookings_prefs.dart';
import '../Colors/colors.dart';
import '../LoginScreens/loginscreen.dart';
import '../Parent/screens/ParentReportsScreen.dart';
import '../Profile/profile_drawer_screen.dart';

import '../api/appointment_api.dart';
import '../utils/api_helpers.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  int pendingCount = 0;
  int newReportsCount = 0;
  final String parentId = "parent_001"; //  لاحقاً من بيانات المستخدم الحقيقي

  @override
  void initState() {
    super.initState();
    _loadPendingCount();
    _loadNewReportsCount();
  }

  Future<void> _loadPendingCount() async {
    try {
      final sessionToken = await APIHelpers.getSessionToken();
      final userId = await APIHelpers.getUserId();
      if (sessionToken == null || userId == null) return;
      
      final appointments = await AppointmentAPI.getChildAppointments(
          sessionToken: sessionToken, 
          childId: userId 
      );
      
      if (mounted) {
        setState(() {
          pendingCount = appointments.where((a) => a['status'] == 'pending').length;
        });
      }
    } catch (e) {
      print("Failed to load pending count: $e");
    }
  }

  Future<void> _loadNewReportsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt("new_reports_count_$parentId") ?? 0;
    setState(() => newReportsCount = count);
  }

  Future<void> _resetNewReportsCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("new_reports_count_$parentId", 0);
    setState(() => newReportsCount = 0);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
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
            leading: const Icon(Icons.person),
            title: const Text("الملف الشخصي"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileDrawerScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.wallet),
            title: const Text("المحفظة"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletScreenUpdated()),
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

          // ✅ قسم التقارير الطبية
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("التقارير الطبية"),
                if (newReportsCount > 0)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      "$newReportsCount",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ParentReportsScreen(parentId: parentId),
                ),
              ).then((_) => _resetNewReportsCount());
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
