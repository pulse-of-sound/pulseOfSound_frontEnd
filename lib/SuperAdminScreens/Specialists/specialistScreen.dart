import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Colors/colors.dart';
import '../../api/user_api.dart';
import '../../utils/shared_pref_helper.dart';
import 'package:pulse_of_sound/SuperAdminScreens/Specialists/modelSpecialists.dart';

import 'addSpecialistScreen.dart';
import 'editSpecialistScreen.dart';

class Specialistscreen extends StatefulWidget {
  const Specialistscreen({super.key});

  @override
  State<Specialistscreen> createState() => _SpecialistscreenState();
}

class _SpecialistscreenState extends State<Specialistscreen> {
  List<Map<String, dynamic>> specialists = [];
  List<Map<String, dynamic>> filteredSpecialists = [];
  final TextEditingController searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // التحقق من الصلاحيات - SuperAdmin و Admin يمكنهم الوصول
    if (!SharedPrefsHelper.hasAdminPermissions()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ليس لديك صلاحية للوصول إلى هذه الصفحة'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }
    _loadSpecialists();
  }

  Future<void> _loadSpecialists() async {
    setState(() => _isLoading = true);
    try {
      final sessionToken = await SharedPrefsHelper.getToken();
      if (sessionToken != null && sessionToken.isNotEmpty) {
        final specialistsList = await UserAPI.getAllSpecialists(sessionToken);
        setState(() {
          specialists = specialistsList;
          filteredSpecialists = specialistsList;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('خطأ في تحميل الأخصائيين: $e');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterSpecialist(String query) {
    final filtered = specialists.where((specialist) {
      final nameMatch = (specialist['fullName'] ?? specialist['username'] ?? '').toString().contains(query);
      final phoneMatch = (specialist['mobile'] ?? '').toString().contains(query);
      return nameMatch || phoneMatch;
    }).toList();

    setState(() => filteredSpecialists = filtered);
  }

  void _addSpecialist(Specialist specialist) {
    _loadSpecialists();
  }

  Future<void> _editSpecialist(int index) async {
    final specialistData = filteredSpecialists[index];
    final specialist = Specialist(
      name: specialistData['fullName'] ?? specialistData['username'] ?? '',
      phone: specialistData['mobile'] ?? '',
      email: specialistData['email'],
      password: '', // لن نعرض كلمة المرور
      birthDate: '',
      certificates: '',
      experience: '',
      workplace: '',
    );
    
    final specialistId = specialistData['id'] ?? specialistData['objectId'];
    final username = specialistData['username'] ?? '';
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditSpecialistPage(
          specialist: specialist,
          specialistId: specialistId,
          originalUsername: username, // تمرير username الأصلي
        ),
      ),
    );
    
    if (result == true) {
      _loadSpecialists();
    }
  }

  Future<void> _deleteSpecialist(int index) async {
    final specialistName = filteredSpecialists[index]['fullName'] ?? 'الأخصائي';
    bool confirm = await _showConfirmDialog(specialistName);
    if (confirm) {
      try {
        final sessionToken = await SharedPrefsHelper.getToken();
        final specialistId = filteredSpecialists[index]['objectId'] ?? filteredSpecialists[index]['id'];
        
        if (sessionToken != null && sessionToken.isNotEmpty && specialistId != null) {
          final result = await UserAPI.deleteSpecialist(sessionToken, specialistId);
          if (!result.containsKey('error')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حذف الأخصائي بنجاح'), backgroundColor: Colors.green)
            );
            _loadSpecialists();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['error']), backgroundColor: Colors.red)
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<bool> _showConfirmDialog(String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              "تأكيد الحذف",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            content: Text("هل تريد حذف الأخصائي ($name)؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "إلغاء",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("حذف"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  الخلفية
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Admin.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.25)),
          SafeArea(
            child:

                // شريط علوي
                Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "إدارة الأخصائيين",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 6),
                              ]),
                        ),
                      ),
                      const SizedBox(
                        width: 48,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),

//  البحث
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      //  هنا حل الخطأ
                      color: Colors.transparent,
                      child: TextField(
                        controller: searchController,
                        onChanged: _filterSpecialist,
                        decoration: InputDecoration(
                          hintText: "ابحث باسم الأخصائي أو رقم الموبايل...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  //  القائمة
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : filteredSpecialists.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا يوجد أخصائيين',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredSpecialists.length,
                                itemBuilder: (context, index) {
                                  final specialist = filteredSpecialists[index];
                                  final specialistName = specialist['fullName'] ?? specialist['username'] ?? 'بدون اسم';
                                  final specialistPhone = specialist['mobile'] ?? 'بدون رقم';
                                  
                                  return Card(
                                    color: Colors.white.withOpacity(0.9),
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    elevation: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            backgroundColor: AppColors.skyBlue,
                                            radius: 26,
                                            child:
                                                Icon(Icons.person, color: Colors.white),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  specialistName,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  "هاتف: $specialistPhone",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54),
                                                ),
                                                if (specialist['email'] != null && specialist['email']!.isNotEmpty)
                                                  Text(
                                                    "بريد: ${specialist['email']}",
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (SharedPrefsHelper.hasAdminPermissions())
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      color: Colors.blue),
                                                  onPressed: () => _editSpecialist(index),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.redAccent),
                                                  onPressed: () => _deleteSpecialist(index),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      //  زر الإضافة - متاح لـ SuperAdmin و Admin
      floatingActionButton: SharedPrefsHelper.hasAdminPermissions()
          ? FloatingActionButton(
              backgroundColor: AppColors.skyBlue,
              onPressed: () async {
                final newDoctor = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddSpecialistPage()),
                );
                if (newDoctor != null) _addSpecialist(newDoctor);
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
