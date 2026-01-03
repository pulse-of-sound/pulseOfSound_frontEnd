import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse_of_sound/LoginScreens/loginscreen.dart';
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
    setState(() => _isLoading = true);
    try {
      final sessionToken = SharedPrefsHelper.getToken();
      if (sessionToken == null || sessionToken.isEmpty) {
        _loadFromLocalStorage();
        setState(() => _isLoading = false);
        return;
      }

      final profile = await UserAPI.getMyProfile(sessionToken);
      
      if (profile.containsKey('error')) {
        _loadFromLocalStorage();
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        nameController.text = profile['fullName']?.toString() ?? profile['username']?.toString() ?? '';
        emailController.text = profile['email']?.toString() ?? '';
        phoneController.text = (profile['mobile'] ?? profile['mobileNumber'])?.toString() ?? '';
        specialtyController.text = profile['specialty']?.toString() ?? '';
        if (profile['profilePic'] != null && profile['profilePic'] is Map) {
          _serverImageUrl = profile['profilePic']['url'];
        }
      });
      
      // Save to local for fallback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_name', nameController.text);
      await prefs.setString('admin_phone', phoneController.text);
      await prefs.setString('admin_email', emailController.text);
      if (_serverImageUrl != null) await prefs.setString('admin_image_url', _serverImageUrl!);

    } catch (e) {
      _loadFromLocalStorage();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _serverImageUrl;
  Uint8List? _webImage;
  File? _profileImage;

  Future<void> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('admin_name') ?? 'غير معروف';
      specialtyController.text = prefs.getString('admin_specialty') ?? '';
      phoneController.text = prefs.getString('admin_phone') ?? '';
      emailController.text = prefs.getString('admin_email') ?? '';
      _imagePath = prefs.getString('admin_image');
      _serverImageUrl = prefs.getString('admin_image_url');
    });
  }

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء الاسم'))
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sessionToken = SharedPrefsHelper.getToken();
      final userId = SharedPrefsHelper.getUserId();
      
      if (sessionToken == null || sessionToken.isEmpty) {
        throw 'لم يتم العثور على جلسة';
      }

      // 1. رفع الصورة إذا تم اختيار صورة جديدة
      Map<String, dynamic>? profilePicFile;
      if (_webImage != null || _profileImage != null) {
        final Uint8List? bytes = kIsWeb ? _webImage : await _profileImage?.readAsBytes();
        if (bytes != null) {
          final String fileName = "profile_admin_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg";
          final uploadResult = await UserAPI.uploadFile(
            bytes: bytes,
            filename: fileName,
            sessionToken: sessionToken,
          );
          
          if (!uploadResult.containsKey('error')) {
            profilePicFile = {
              "__type": "File",
              "name": uploadResult['name'],
              "url": uploadResult['url'],
            };
          }
        }
      }

      // 2. تحديث الحساب
      final result = await UserAPI.updateMyAccount(
        sessionToken: sessionToken,
        fullName: nameController.text.trim(),
        mobileNumber: phoneController.text.trim(),
        specialty: specialtyController.text.trim(),
        profilePic: profilePicFile,
      );

      if (result.containsKey('error')) {
        throw result['error'];
      }

      // 3. تحديث الحالة المحلية
      if (result['profilePic'] != null) {
        setState(() {
          _serverImageUrl = result['profilePic']['url'];
          _webImage = null;
          _profileImage = null;
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_name', nameController.text.trim());
      await prefs.setString('admin_phone', phoneController.text.trim());
      await prefs.setString('admin_email', emailController.text.trim());
      if (_serverImageUrl != null) await prefs.setString('admin_image_url', _serverImageUrl!);
      
      setState(() => isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التعديلات بنجاح'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imagePath = pickedFile.path;
        });
      } else {
        setState(() {
          _profileImage = File(pickedFile.path);
          _imagePath = pickedFile.path;
        });
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_image', pickedFile.path);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = false, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters, String? prefixText}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
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
                  onTap: isEditing ? _pickImage : null,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    backgroundImage: kIsWeb
                        ? (_webImage != null ? MemoryImage(_webImage!) : (_serverImageUrl != null ? NetworkImage(_serverImageUrl!) : null) as ImageProvider?)
                        : (_profileImage != null ? FileImage(_profileImage!) : (_serverImageUrl != null ? NetworkImage(_serverImageUrl!) : null) as ImageProvider?),
                    child: (kIsWeb ? (_webImage == null && _serverImageUrl == null) : (_profileImage == null && _serverImageUrl == null))
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
                    enabled: isEditing,
                    keyboardType: TextInputType.phone,
                    prefixText: '+963 ',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ]),
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
