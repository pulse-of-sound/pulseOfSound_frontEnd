import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse_of_sound/PreTestIntro/preTestIntroScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/user_api.dart';
import '../utils/shared_pref_helper.dart';
import '../api/child_api.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  
  final _healthController = TextEditingController();
  String? _gender;
  File? _profileImage;
  Uint8List? _webImage;
  String? _serverImageUrl;
  bool _isLoading = false;

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
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
        } else {
          setState(() {
            _profileImage = File(pickedFile.path);
          });
        }
        await SharedPrefsHelper.setProfileImage(pickedFile.path);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم اختيار الصورة بنجاح"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في اختيار الصورة: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    //  محاولة الجلب من السيرفر أولاً
    try {
      final sessionToken = SharedPrefsHelper.getToken();
      final userRole = SharedPrefsHelper.getUserType();
      
      if (sessionToken != null && sessionToken.isNotEmpty) {
        print(" Loading profile from server (Role: $userRole)...");
        
        dynamic profile;
        if (userRole == "Child" || userRole == null) {
          profile = await ChildProfileAPI.getMyChildProfile(sessionToken: sessionToken);
        } else {
          profile = await UserAPI.getMyProfile(sessionToken);
        }
        
        if (profile != null && !profile.containsKey('error') && mounted) {
          print(" Profile loaded from server");
          
          setState(() {
            _nameController.text = (profile['name'] ?? profile['fullName'])?.toString() ?? "";
            _fatherNameController.text = profile['fatherName']?.toString() ?? "";
            
            // التعامل مع تاريخ الميلاد
            final dynamic bDate = profile['birthdate'] ?? profile['birthDate'];
            if (bDate != null) {
              if (bDate is String) {
                _birthDateController.text = bDate;
              } else if (bDate is Map && bDate['iso'] != null) {
                try {
                  DateTime dt = DateTime.parse(bDate['iso']);
                  _birthDateController.text = "${dt.day}/${dt.month}/${dt.year}";
                } catch (e) {
                  _birthDateController.text = "";
                }
              }
            }
            
            _gender = profile['gender']?.toString();
           
            _healthController.text = profile['medical_info']?.toString() ?? "";
            
            // محاولة جلب صورة البروفايل
            if (profile['profilePic'] != null && profile['profilePic'] is Map) {
              _serverImageUrl = profile['profilePic']['url'];
            } else if (profile['user'] != null && profile['user'] is Map && profile['user']['profilePic'] != null) {
              _serverImageUrl = profile['user']['profilePic']['url'];
            }
          });
          
          // حفظ محلياً للاستخدام السريع
          await SharedPrefsHelper.setName(_nameController.text);
          await SharedPrefsHelper.setFatherName(_fatherNameController.text);
          await SharedPrefsHelper.setBirthDate(_birthDateController.text);
          if (_gender != null) await SharedPrefsHelper.setGender(_gender!);
        
          await SharedPrefsHelper.setHealthStatus(_healthController.text);
          
          return;
        }
      }
    } catch (e) {
      print(" Exception loading profile: $e");
    }

    // Fallback to local
    print(" Loading profile from local storage");
    if (!kIsWeb) {
      final imagePath = SharedPrefsHelper.getProfileImage();
      if (imagePath != null && File(imagePath).existsSync()) {
        setState(() => _profileImage = File(imagePath));
      }
    }

    setState(() {
      String name = SharedPrefsHelper.getName() ?? "";
      if (name.isEmpty || _isSessionToken(name)) name = "child";
      
      _nameController.text = name;
      _fatherNameController.text = SharedPrefsHelper.getFatherName() ?? "";
      _birthDateController.text = SharedPrefsHelper.getBirthDate() ?? "";
      _gender = SharedPrefsHelper.getGender();
    
      _healthController.text = SharedPrefsHelper.getHealthStatus() ?? "";
    });
  }
  
  bool _isSessionToken(String text) {
    return text.length > 20 || text.contains(RegExp(r'^[a-zA-Z0-9]{20,}$'));
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) setState(() => _isLoading = true);
      
      try {
        final sessionToken = SharedPrefsHelper.getToken();
        final childId = SharedPrefsHelper.getUserId();
        final userRole = SharedPrefsHelper.getUserType();
        
        if (sessionToken != null && childId != null && childId.isNotEmpty) {
          print(" Saving profile to server...");
          
          // 1. رفع الصورة...
          Map<String, dynamic>? profilePicFile;
          if (_webImage != null || _profileImage != null) {
            final Uint8List? bytes = kIsWeb ? _webImage : await _profileImage?.readAsBytes();
            if (bytes != null) {
              final String fileName = "profile_${childId}_${DateTime.now().millisecondsSinceEpoch}.jpg";
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

          // 2. تحديث بيانات الحساب (User)
          final accountResult = await UserAPI.updateMyAccount(
            sessionToken: sessionToken,
            fullName: _nameController.text,
            fatherName: _fatherNameController.text,
            birthDate: _birthDateController.text,
            gender: _gender,
            medicalInfo: _healthController.text,
        
            profilePic: profilePicFile,
          );

          if (accountResult.containsKey('error')) {
            throw accountResult['error'];
          }

          // تحديث الصورة في الواجهة إذا عادت من السيرفر
          if (accountResult.containsKey('profilePic') && accountResult['profilePic'] != null) {
            if (mounted) {
              setState(() {
                _serverImageUrl = accountResult['profilePic']['url'];
                _profileImage = null;
                _webImage = null;
              });
            }
          }

          // 3. تحديث بيانات ملف الطفل (إذا كان يوزر طفل)
          if (userRole == "Child" || userRole == null) {
            final childResult = await ChildProfileAPI.createOrUpdateChildProfile(
              childId: childId,
              name: _nameController.text,
              fatherName: _fatherNameController.text,
              birthdate: _birthDateController.text,
              gender: _gender,
              medicalInfo: _healthController.text,
            );
            if (childResult.containsKey('error')) {
              throw childResult['error'];
            }
          }
          
          // حفظ محلياً
          await SharedPrefsHelper.setName(_nameController.text);
          await SharedPrefsHelper.setFatherName(_fatherNameController.text);
          await SharedPrefsHelper.setBirthDate(_birthDateController.text);
          if (_gender != null) await SharedPrefsHelper.setGender(_gender!);
          
          await SharedPrefsHelper.setHealthStatus(_healthController.text);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("تم حفظ التعديلات بنجاح"), backgroundColor: Colors.green),
            );
            
            // التوجيه إذا كان طفلاً
            if (userRole.toLowerCase() == "child" || userRole == "guest") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PreTestIntroScreen()),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("خطأ في الحفظ: $e"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية ناعمة
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/profile1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // المحتوى
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
                          backgroundImage: kIsWeb
                              ? (_webImage != null ? MemoryImage(_webImage!) : (_serverImageUrl != null ? NetworkImage(_serverImageUrl!) : null) as ImageProvider?)
                              : (_profileImage != null ? FileImage(_profileImage!) : (_serverImageUrl != null ? NetworkImage(_serverImageUrl!) : null) as ImageProvider?),
                          child: (kIsWeb ? (_webImage == null && _serverImageUrl == null) : (_profileImage == null && _serverImageUrl == null))
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
                            "حفظ ومتابعة",
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
      {bool readOnly = false,
      VoidCallback? onTap,
      bool isRequired = true,
      TextInputType? keyboardType,
      String? prefixText,
      List<TextInputFormatter>? inputFormatters,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextFormField(
            controller: c,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textAlign: TextAlign.right,
            decoration: _inputDecoration(h, i, prefixText: prefixText),
            validator: validator ??
                (v) => isRequired && (v == null || v.isEmpty)
                    ? "هذا الحقل إجباري"
                    : null,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.pinkAccent),
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
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
