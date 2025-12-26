import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse_of_sound/LoginScreens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Colors/colors.dart';
import '../../api/user_api.dart';
import '../../utils/shared_pref_helper.dart';
import '../utils/doctor_wallet_prefs.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isEditing = false;
  double balance = 0.0;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final sessionToken = SharedPrefsHelper.getToken();
      if (sessionToken == null || sessionToken.isEmpty) {
        _loadFromLocalStorage();
        return;
      }

      final profile = await UserAPI.getMyProfile(sessionToken);
      
      if (profile.containsKey('error')) {
        _loadFromLocalStorage();
        return;
      }

      setState(() {
        nameController.text = profile['fullName'] ?? profile['username'] ?? '';
        emailController.text = profile['email'] ?? '';
        phoneController.text = profile['mobileNumber'] ?? '';
        specialtyController.text = profile['specialty'] ?? '';
      });
    } catch (e) {
      _loadFromLocalStorage();
    }

    balance = await DoctorWalletPrefs.getBalance();
    setState(() {});
  }

  Future<void> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('doctor_name') ?? 'د. غير معروف';
      specialtyController.text =
          prefs.getString('doctor_specialty') ?? 'أخصائي نفسي';
      phoneController.text = prefs.getString('doctor_phone') ?? 'غير محدد';
      emailController.text = prefs.getString('doctor_email') ?? 'غير محدد';
      _imagePath = prefs.getString('doctor_image');
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctor_name', nameController.text.trim());
    await prefs.setString('doctor_specialty', specialtyController.text.trim());
    await prefs.setString('doctor_phone', phoneController.text.trim());
    await prefs.setString('doctor_email', emailController.text.trim());
    if (_imagePath != null) await prefs.setString('doctor_image', _imagePath!);
    setState(() => isEditing = false);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('doctor_image', picked.path);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = false}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/doctorsBackground.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(children: [
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "الملف الشخصي",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 6)
                          ]),
                    ),
                  ),
                  const SizedBox(width: 40),
                ]),
                const SizedBox(height: 20),

                //  صورة الطبيب
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    backgroundImage: _imagePath != null
                        ? (kIsWeb
                            ? NetworkImage(_imagePath!)
                            : FileImage(File(_imagePath!))) as ImageProvider
                        : null,
                    child: _imagePath == null
                        ? const Icon(Icons.camera_alt,
                            size: 50, color: AppColors.skyBlue)
                        : null,
                  ),
                ),

                const SizedBox(height: 25),

                const SizedBox(height: 20),

                //  الحقول النصية
                _buildTextField("الاسم الكامل", nameController,
                    enabled: isEditing),
                const SizedBox(height: 10),
                _buildTextField("الاختصاص", specialtyController,
                    enabled: isEditing),
                const SizedBox(height: 10),
                _buildTextField("رقم الهاتف", phoneController,
                    enabled: isEditing),
                const SizedBox(height: 10),
                _buildTextField("البريد الإلكتروني", emailController,
                    enabled: isEditing),

                const SizedBox(height: 25),

                //  الأزرار
                if (!isEditing)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => isEditing = true),
                    icon: const Icon(Icons.edit),
                    label: const Text("تعديل البيانات"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.skyBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save_alt),
                    label: const Text("حفظ التعديلات"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text("تسجيل الخروج"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
