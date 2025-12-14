import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Colors/colors.dart';
import '../../api/user_api.dart';
import '../../utils/shared_pref_helper.dart';

import 'addDoctorScreen.dart';

import 'editDoctorScreen.dart';
import 'modelDoctor.dart';

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> filteredDoctors = [];
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
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final sessionToken = SharedPrefsHelper.getToken();
      if (sessionToken != null && sessionToken.isNotEmpty) {
        final doctorsList = await UserAPI.getAllDoctors(sessionToken);
        setState(() {
          doctors = doctorsList;
          filteredDoctors = doctorsList;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('خطأ في تحميل الأطباء: $e');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterDoctors(String query) {
    final filtered = doctors.where((doctor) {
      final nameMatch = (doctor['fullName'] ?? doctor['username'] ?? '').toString().contains(query);
      final phoneMatch = (doctor['mobile'] ?? '').toString().contains(query);
      return nameMatch || phoneMatch;
    }).toList();

    setState(() => filteredDoctors = filtered);
  }

  void _addDoctor(Doctor doctor) {
    _loadDoctors();
  }

  Future<void> _editDoctor(int index) async {
    final doctorData = filteredDoctors[index];
    final doctor = Doctor(
      name: doctorData['fullName'] ?? doctorData['username'] ?? '',
      phone: doctorData['mobile'] ?? '',
      email: doctorData['email'],
      password: '', // لن نعرض كلمة المرور
      birthDate: '',
      certificates: '',
      experience: '',
      workplace: '',
    );
    
    final doctorId = doctorData['id'] ?? doctorData['objectId'];
    final username = doctorData['username'] ?? '';
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditDoctorPage(
          doctor: doctor,
          doctorId: doctorId,
          originalUsername: username, // تمرير username الأصلي
        ),
      ),
    );
    
    if (result == true) {
      _loadDoctors();
    }
  }

  Future<void> _deleteDoctor(int index) async {
    final doctorName = filteredDoctors[index]['fullName'] ?? 'الطبيب';
    bool confirm = await _showConfirmDialog(doctorName);
    if (confirm) {
      try {
        final sessionToken = SharedPrefsHelper.getToken();
        final doctorId = filteredDoctors[index]['objectId'] ?? filteredDoctors[index]['id'];
        
        print(" DEBUG: sessionToken = $sessionToken");
        print(" DEBUG: sessionToken length = ${sessionToken?.length}");
        print(" DEBUG: doctorId = $doctorId");
        
        if (sessionToken != null && sessionToken.isNotEmpty && doctorId != null) {
          final result = await UserAPI.deleteDoctor(sessionToken, doctorId);
          if (!result.containsKey('error')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حذف الطبيب بنجاح'), backgroundColor: Colors.green)
            );
            _loadDoctors();
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
            content: Text("هل تريد حذف الطبيب ($name)؟"),
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

                //  شريط علوي
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
                          "إدارة الأطباء",
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
                        onChanged: _filterDoctors,
                        decoration: InputDecoration(
                          hintText: "ابحث باسم الطبيب أو رقم الموبايل...",
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
                        : filteredDoctors.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا توجد أطباء',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredDoctors.length,
                                itemBuilder: (context, index) {
                                  final doctor = filteredDoctors[index];
                                  final doctorName = doctor['fullName'] ?? doctor['username'] ?? 'بدون اسم';
                                  final doctorPhone = doctor['mobile'] ?? 'بدون رقم';
                                  
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
                                                  doctorName,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  "هاتف: $doctorPhone",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54),
                                                ),
                                                if (doctor['email'] != null && doctor['email']!.isNotEmpty)
                                                  Text(
                                                    "بريد: ${doctor['email']}",
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
                                                  onPressed: () => _editDoctor(index),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.redAccent),
                                                  onPressed: () => _deleteDoctor(index),
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
                  MaterialPageRoute(builder: (_) => const AddDoctorPage()),
                );
                if (newDoctor != null) _addDoctor(newDoctor);
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
