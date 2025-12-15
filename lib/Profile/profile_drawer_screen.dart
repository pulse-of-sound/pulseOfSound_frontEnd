import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/shared_pref_helper.dart';
import '../api/child_api.dart';

class ProfileDrawerScreen extends StatefulWidget {
  const ProfileDrawerScreen({super.key});

  @override
  State<ProfileDrawerScreen> createState() => _ProfileDrawerScreenState();
}

class _ProfileDrawerScreenState extends State<ProfileDrawerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _healthController = TextEditingController();
  String? _gender;
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // 1. محاولة الجلب من السيرفر أولاً
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('session_token');
      
      if (sessionToken != null && sessionToken.isNotEmpty) {
        print("🔄 Loading profile from server...");
        
        final profile = await ChildProfileAPI.getMyChildProfile(
          sessionToken: sessionToken,
        );
        
        if (!profile.containsKey('error') && mounted) {
          print("✅ Profile loaded from server");
          
          setState(() {
            _nameController.text = profile['name'] ?? "";
            _fatherNameController.text = profile['fatherName'] ?? "";
            _birthDateController.text = profile['birthdate'] ?? "";
            _gender = profile['gender'];
            _healthController.text = profile['medical_info'] ?? "";
          });
          
          // حفظ محلياً للاستخدام السريع
          await SharedPrefsHelper.setName(profile['name'] ?? "");
          await SharedPrefsHelper.setFatherName(profile['fatherName'] ?? "");
          await SharedPrefsHelper.setBirthDate(profile['birthdate'] ?? "");
          await SharedPrefsHelper.setGender(profile['gender'] ?? "");
          await SharedPrefsHelper.setHealthStatus(profile['medical_info'] ?? "");
          
          // تحميل الصورة المحلية
          final imagePath = SharedPrefsHelper.getProfileImage();
          if (imagePath != null && File(imagePath).existsSync()) {
            setState(() => _profileImage = File(imagePath));
          }
          
          return;
        } else {
          print("⚠️ Failed to load from server: ${profile['error']}");
        }
      }
    } catch (e) {
      print("❌ Exception loading profile: $e");
    }
    
    // 2. إذا فشل، اجلب من المحلي (Fallback)
    print("📂 Loading profile from local storage");
    final imagePath = SharedPrefsHelper.getProfileImage();
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() => _profileImage = File(imagePath));
    }

    setState(() {
      _nameController.text = SharedPrefsHelper.getName() ?? "";
      _fatherNameController.text = SharedPrefsHelper.getFatherName() ?? "";
      _birthDateController.text = SharedPrefsHelper.getBirthDate() ?? "";
      _gender = SharedPrefsHelper.getGender();
      _healthController.text = SharedPrefsHelper.getHealthStatus() ?? "";
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // 1. حفظ في السيرفر أولاً
      try {
        final prefs = await SharedPreferences.getInstance();
        final childId = prefs.getString('child_id');
        
        if (childId != null && childId.isNotEmpty) {
          print("💾 Updating profile on server for child: $childId");
          
          final result = await ChildProfileAPI.createOrUpdateChildProfile(
            childId: childId,
            name: _nameController.text,
            fatherName: _fatherNameController.text,
            birthdate: _birthDateController.text,
            gender: _gender,
            medicalInfo: _healthController.text,
          );
          
          if (result.containsKey('error')) {
            print("❌ Error updating profile: ${result['error']}");
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطأ في الحفظ: ${result['error']}'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
          } else {
            print("✅ Profile updated successfully on server");
          }
        }
      } catch (e) {
        print("❌ Exception updating profile: $e");
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في الاتصال: $e'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      
      // 2. حفظ محلياً
      await SharedPrefsHelper.setName(_nameController.text);
      await SharedPrefsHelper.setFatherName(_fatherNameController.text);
      await SharedPrefsHelper.setBirthDate(_birthDateController.text);
      await SharedPrefsHelper.setGender(_gender ?? "");
      await SharedPrefsHelper.setHealthStatus(_healthController.text);
      if (_profileImage != null) {
        await SharedPrefsHelper.setProfileImage(_profileImage!.path);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ تم حفظ التعديلات بنجاح"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
      await SharedPrefsHelper.setProfileImage(pickedFile.path);
    }
  }

  Future<void> _pickBirthDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2015, 1, 1),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "الملف الشخصي",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // خلفية ناعمة
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/profile1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // صورة الطفل
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.pinkAccent.withOpacity(0.7),
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(Icons.camera_alt,
                                  size: 45, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildField(
                          _nameController, "الاسم الكامل", Icons.person),
                      _buildField(_fatherNameController, "اسم الأب",
                          Icons.family_restroom),
                      _buildField(_birthDateController, "تاريخ الميلاد",
                          Icons.calendar_today,
                          readOnly: true, onTap: _pickBirthDate),

                      // الجنس

                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                              height: 50, //

                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(80),
                                border: Border.all(
                                  color: Colors.pinkAccent.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // الأيقونة تبقى عاليسار
                                  const Icon(Icons.wc,
                                      color: Colors.pinkAccent),

                                  const SizedBox(width: 8),
                                  //  Dropdown فيه النص والسهم عاليمين
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _gender,
                                          isExpanded: true,
                                          alignment: Alignment.centerRight,
                                          dropdownColor: const Color.fromARGB(
                                              200, 255, 230, 240),
                                          icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.pinkAccent),
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                          ),
                                          hint: const Align(
                                            alignment: Alignment.centerRight,
                                            child: Text("الجنس"),
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: "ذكر",
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text("ذكر"),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: "أنثى",
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text("أنثى"),
                                              ),
                                            ),
                                          ],
                                          onChanged: (val) =>
                                              setState(() => _gender = val),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildField(_healthController, "الحالة الصحية (اختياري)",
                          Icons.local_hospital,
                          isRequired: false),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            "حفظ التعديلات",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController c, String h, IconData i,
      {bool readOnly = false, VoidCallback? onTap, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextFormField(
            controller: c,
            readOnly: readOnly,
            onTap: onTap,
            textAlign: TextAlign.right,
            decoration: _inputDecoration(h, i),
            validator: (v) => isRequired && (v == null || v.isEmpty)
                ? "هذا الحقل إجباري"
                : null,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.pinkAccent),
      hintStyle: const TextStyle(color: Colors.black87, fontSize: 15),
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: Colors.pinkAccent.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
      ),
    );
  }
}
