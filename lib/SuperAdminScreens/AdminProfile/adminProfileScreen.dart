import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse_of_sound/LoginScreens/loginscreen.dart';
import 'package:pulse_of_sound/SuperAdminScreens/Admin/modelAdmin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/user_api.dart';
import '../../utils/shared_pref_helper.dart';
import '../../Colors/colors.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isEditing = false;
  bool _isLoading = false;
  double balance = 0.0;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    specialtyController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('admin_name') ?? ' غير معروف';
      specialtyController.text =
          prefs.getString('admin_specialty') ?? 'غير معروف ';
      phoneController.text = prefs.getString('admin_phone') ?? 'غير محدد';
      emailController.text = prefs.getString('admin_email') ?? 'غير محدد';
      _imagePath = prefs.getString('admin_image');
    });

    setState(() {});
  }

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء الاسم والبريد الإلكتروني'))
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sessionToken = SharedPrefsHelper.getToken();
      if (sessionToken == null || sessionToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على جلسة'))
        );
        setState(() => _isLoading = false);
        return;
      }

      final result = await UserAPI.updateMyAccount(
        sessionToken,
        fullName: nameController.text.trim(),
        mobile: phoneController.text.trim(),
        email: emailController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red)
        );
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_name', nameController.text.trim());
        await prefs.setString('admin_phone', phoneController.text.trim());
        await prefs.setString('admin_email', emailController.text.trim());
        
        setState(() => isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التعديلات بنجاح'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red)
      );
    }
  }

  Future<void> _logout() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      final sessionToken = SharedPrefsHelper.getToken();
      if (sessionToken != null && sessionToken.isNotEmpty) {
        await UserAPI.logout(sessionToken);
      }
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
    }

    if (mounted) {
      await SharedPrefsHelper.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_image', picked.path);
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
              image: AssetImage("images/Admin.jpg"),
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
                    onPressed: _isLoading ? null : () => setState(() => isEditing = true),
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
                    onPressed: _isLoading ? null : _saveProfile,
                    icon: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save_alt),
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
                  onPressed: _isLoading ? null : _logout,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.logout),
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
