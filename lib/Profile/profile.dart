import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse_of_sound/HomeScreens/HomeScreen.dart';
import 'package:pulse_of_sound/PreTestIntro/preTestIntroScreen.dart';
import '../Colors/colors.dart';
import '../utils/shared_pref_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _healthController = TextEditingController();
  String? _gender;
  File? _profileImage;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      await SharedPrefsHelper.setProfileImage(pickedFile.path);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await SharedPrefsHelper.setName(_nameController.text);
      await SharedPrefsHelper.setFatherName(_fatherNameController.text);
      await SharedPrefsHelper.setAge(int.parse(_ageController.text));
      await SharedPrefsHelper.setBirthDate(_birthDateController.text);
      await SharedPrefsHelper.setGender(_gender ?? "");
      await SharedPrefsHelper.setHealthStatus(_healthController.text);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PreTestIntroScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      final imagePath = SharedPrefsHelper.getProfileImage();
      if (imagePath != null) {
        _profileImage = File(imagePath);
      }
      _nameController.text = SharedPrefsHelper.getName() ?? "";
      _fatherNameController.text = SharedPrefsHelper.getFatherName() ?? "";
      _ageController.text = SharedPrefsHelper.getAge()?.toString() ?? "";
      _birthDateController.text = SharedPrefsHelper.getBirthDate() ?? "";
      _gender = SharedPrefsHelper.getGender();
      _healthController.text = SharedPrefsHelper.getHealthStatus() ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("الملف الشخصي"),
        centerTitle: true,
        backgroundColor: AppColors.babyPink,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // صورة البروفايل
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.skyBlue.withOpacity(0.3),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt,
                            size: 40, color: Colors.white70)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  controller: _nameController,
                  label: "الاسم الكامل",
                  icon: Icons.person,
                  isRequired: true,
                ),
                _buildTextField(
                  controller: _fatherNameController,
                  label: "اسم الأب",
                  icon: Icons.person_outline,
                  isRequired: true,
                ),
                _buildTextField(
                  controller: _ageController,
                  label: "العمر",
                  icon: Icons.cake,
                  keyboard: TextInputType.number,
                  isRequired: true,
                ),
                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  onTap: _pickBirthDate,
                  decoration: const InputDecoration(
                    labelText: "تاريخ الميلاد",
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "هذا الحقل إجباري" : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    labelText: "الجنس",
                    prefixIcon: Icon(Icons.wc),
                  ),
                  items: const [
                    DropdownMenuItem(value: "ذكر", child: Text("ذكر")),
                    DropdownMenuItem(value: "أنثى", child: Text("أنثى")),
                  ],
                  onChanged: (val) => setState(() => _gender = val),
                  validator: (v) =>
                      v == null || v.isEmpty ? "هذا الحقل إجباري" : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _healthController,
                  label: "الحالة الصحية (اختياري)",
                  icon: Icons.local_hospital,
                  isRequired: false,
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.skyBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "حفظ ومتابعة",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: isRequired
            ? (v) => v == null || v.isEmpty ? "هذا الحقل إجباري" : null
            : null,
      ),
    );
  }
}
