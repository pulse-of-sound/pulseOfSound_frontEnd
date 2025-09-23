import 'package:flutter/material.dart';
import 'package:pulse_of_sound/SuperAdminScreens/DashBoard/dashBoard.dart';
import 'package:pulse_of_sound/SuperAdminScreens/Specialists/specialistScreen.dart';
import '../SuperAdminScreens/Admin/adminScreen.dart';
import '../SuperAdminScreens/Childrens/chidScreen.dart';
import '../SuperAdminScreens/Doctors/doctorsScreen.dart';
import '../Colors/colors.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة النظام"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(context, "لوحة التحكم", "icons/icons8-dashboard-40.png",
                const DashboardPage()),
            _buildCard(context, "الأطباء", "icons/icons8-doctors-60.png",
                const DoctorsPage()),
            _buildCard(context, "الأخصائيين",
                "icons/icons8-mental-health-64.png", const SpecialistsPage()),
            _buildCard(context, "الأطفال", "icons/icons8-children-64.png",
                const ChildrenPage()),
            _buildCard(context, "الأدمن", "icons/icons8-admin-50.png",
                const AdminsPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, String iconPath, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Card(
        color: AppColors.pastelBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.9),
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
