import 'package:flutter/material.dart';
import '../../Colors/colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة التحكم"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Cards إحصائيات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("عدد الأطباء", "12", Icons.medical_services,
                    AppColors.skyBlue),
                _buildStatCard(
                    "الأخصائيين", "8", Icons.psychology_alt, AppColors.peach),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                    "الأطفال", "24", Icons.child_care, AppColors.babyPink),
                _buildStatCard(
                    "الأدمن", "3", Icons.admin_panel_settings, AppColors.pink),
              ],
            ),
            const SizedBox(height: 24),

            // مخطط (مؤقت شكل دائري/Progress)
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      "نسبة التقدم",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 0.75, // 75% تقدم
                            strokeWidth: 12,
                            backgroundColor: AppColors.butter.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.skyBlue,
                            ),
                          ),
                          const Text(
                            "75%",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
