import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pulse_of_sound/SuperAdminScreens/DashBoard/dashBoard.dart';
import 'package:pulse_of_sound/SuperAdminScreens/Specialists/specialistScreen.dart';
import '../SuperAdminScreens/Admin/adminScreen.dart';
import '../SuperAdminScreens/AdminProfile/adminProfileScreen.dart';
import '../SuperAdminScreens/Chats/AdminCommunityChatScreen.dart';
import '../SuperAdminScreens/Childrens/chidScreen.dart';
import '../SuperAdminScreens/Doctors/doctorsScreen.dart';
import '../Colors/colors.dart';
import '../SuperAdminScreens/Wallet/ReceiptsAdminScreen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // الخلفية
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/Admin.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              //  شريط العنوان
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "إدارة النظام",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              //  شبكة الكروت
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildGlassCard(
                        context,
                        " الملف الشخصي",
                        "icons/icons8-dashboard-40.png",
                        const AdminProfileScreen()),
                    _buildGlassCard(context, "لوحة التحكم",
                        "icons/icons8-dashboard-40.png", const DashboardPage()),
                    _buildGlassCard(context, "الأطباء",
                        "icons/icons8-doctors-60.png", const DoctorsPage()),
                    _buildGlassCard(
                        context,
                        "الأخصائيين",
                        "icons/icons8-mental-health-64.png",
                        const Specialistscreen()),
                    _buildGlassCard(context, "الأطفال",
                        "icons/icons8-children-64.png", const ChildrenPage()),
                    _buildGlassCard(context, "الأدمن",
                        "icons/icons8-admin-50.png", const Adminscreen()),
                    _buildGlassCard(
                        context,
                        "الإيصالات",
                        "icons/icons8-wallet-80.png",
                        const ReceiptsAdminScreen()),
                    _buildGlassCard(
                        context,
                        "مجتمع الأهالي",
                        "icons/icons8-conversation-40.png",
                        const AdminCommunityChatScreen()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  كارد زجاجي احترافي
  Widget _buildGlassCard(
      BuildContext context, String title, String iconPath, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), //  تأثير الزجاج
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.4),
                    child: Image.asset(
                      iconPath,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
