import 'package:flutter/material.dart';
import '../../api/appointment_plan_api.dart';
import '../../api/user_api.dart';
import '../../utils/api_helpers.dart';
import '../../Colors/colors.dart';
import 'plan_selection_screen.dart';

class ConsultationFlowScreen extends StatefulWidget {
  final String childId;
  
  const ConsultationFlowScreen({
    super.key,
    required this.childId,
  });

  @override
  State<ConsultationFlowScreen> createState() => _ConsultationFlowScreenState();
}

class _ConsultationFlowScreenState extends State<ConsultationFlowScreen> {
  String? selectedType;
  List<Map<String, dynamic>> providers = [];
  bool isLoadingProviders = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// التحقق من تسجيل الدخول
  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await APIHelpers.isUserLoggedIn();
    if (!isLoggedIn && mounted) {
      // المستخدم غير مسجل دخول
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('تسجيل الدخول مطلوب'),
          content: const Text('يجب تسجيل الدخول أولاً للوصول إلى هذه الميزة'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
              },
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "احجز استشارتك",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/booking.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(20),
            width: selectedType == null ? 300 : 350,
            height: selectedType == null ? 220 : 480,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "اختر نوع الاستشارة:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTypeButton("Doctor", "طبية"),
                    _buildTypeButton("Psychologist", "نفسية"),
                  ],
                ),
                const SizedBox(height: 25),
                if (selectedType != null)
                  Expanded(
                    child: isLoadingProviders
                        ? const Center(child: CircularProgressIndicator())
                        : providers.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا يوجد متخصصون متاحون حالياً',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView(
                                children: [
                                  const Text(
                                    "المتخصصون المتاحون:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  ...providers.map((provider) => ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.skyBlue,
                                          child: Text(
                                            provider['fullName']?[0] ?? 'د',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(provider['fullName'] ?? 'غير معروف'),
                                        subtitle: Text(
                                          provider['specialization'] ?? 'متخصص',
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 18,
                                          color: Colors.pinkAccent,
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PlanSelectionScreen(
                                                childId: widget.childId,
                                                providerId: provider['id'],
                                                providerName: provider['fullName'] ?? 'متخصص',
                                              ),
                                            ),
                                          );
                                        },
                                      )),
                                ],
                              ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, String label) {
    final bool isSelected = selectedType == type;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.pinkAccent : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
      ),
      onPressed: () {
        setState(() {
          selectedType = type;
          providers = [];
        });
        _loadProviders(type);
      },
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _loadProviders(String providerType) async {
    setState(() => isLoadingProviders = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();
      
      // استدعاء API الحقيقي
      final result = await UserAPI.getProvidersByType(
        sessionToken: sessionToken,
        providerType: providerType,
      );
      
      setState(() {
        providers = result;
      });
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'فشل تحميل المتخصصين: $e');
      }
    } finally {
      setState(() => isLoadingProviders = false);
    }
  }
}
