import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/user_api.dart';
import '../../utils/shared_pref_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int doctorCount = 0;
  int specialistCount = 0;
  int childCount = 0;
  int adminCount = 0;
  bool isLoading = true;
  bool isSuperAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('token') ?? '';

      if (sessionToken.isEmpty) {
        // Handle case where session token is missing (maybe redirect to login?)
        print("Session token is missing");
        setState(() {
          isLoading = false;
        });
        return;
      }

      bool isAdmin = SharedPrefsHelper.isAdmin();
      isSuperAdmin = SharedPrefsHelper.isSuperAdmin();

      final futures = await Future.wait([
        UserAPI.getAllDoctors(sessionToken),
        UserAPI.getAllSpecialists(sessionToken),
        UserAPI.getAllChildren(sessionToken),
        UserAPI.getAllAdmins(sessionToken),
      ]);

      if (mounted) {
        setState(() {
          doctorCount = futures[0].length;
          specialistCount = futures[1].length;
          childCount = futures[2].length;
          adminCount = (futures[3] as List).length;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/Admin.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // شريط علوي
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Expanded(
                              child: Text(
                                "لوحة التحكم",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black54,
                                          blurRadius: 6,
                                          offset: Offset(1, 2))
                                    ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // الصف الأول من الإحصائيات
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatCard(
                                "عدد الأطباء",
                                "$doctorCount",
                                Icons.medical_services,
                                AppColors.skyBlue),
                            const SizedBox(width: 16),
                            _buildStatCard(
                                "الأخصائيين",
                                "$specialistCount",
                                Icons.psychology_alt,
                                AppColors.peach),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatCard(
                                "الأطفال",
                                "$childCount",
                                Icons.child_care,
                                AppColors.babyPink),
                            const SizedBox(width: 16),
                            _buildStatCard(
                                "الأدمن",
                                "$adminCount",
                                Icons.admin_panel_settings,
                                AppColors.pink),
                          ],
                        ),
                       
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 26,
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
