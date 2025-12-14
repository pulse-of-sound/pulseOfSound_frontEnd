import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Colors/colors.dart';
import '../../api/user_api.dart';
import '../../utils/shared_pref_helper.dart';
import 'package:pulse_of_sound/SuperAdminScreens/Admin/modelAdmin.dart';

import 'addAdminScreen.dart';
import 'editAdminScreen.dart';

class Adminscreen extends StatefulWidget {
  const Adminscreen({super.key});

  @override
  State<Adminscreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<Adminscreen> {
  List<Map<String, dynamic>> admins = [];
  List<Map<String, dynamic>> filteredAdmins = [];
  final TextEditingController searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // التحقق من الصلاحيات - فقط SuperAdmin يمكنه الوصول
    if (!SharedPrefsHelper.isSuperAdmin()) {
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
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() => _isLoading = true);
    try {
      final sessionToken = SharedPrefsHelper.getToken();
      print(" DEBUG _loadAdmins: sessionToken = '$sessionToken'");
      print(" DEBUG _loadAdmins: sessionToken is null? ${sessionToken == null}");
      print(" DEBUG _loadAdmins: sessionToken isEmpty? ${sessionToken?.isEmpty ?? 'N/A'}");
      print(" DEBUG _loadAdmins: sessionToken length = ${sessionToken?.length}");
      
      if (sessionToken != null && sessionToken.isNotEmpty) {
        final adminsList = await UserAPI.getAllAdmins(sessionToken);
        setState(() {
          admins = adminsList;
          filteredAdmins = adminsList;
          _isLoading = false;
        });
        
        // إذا كانت القائمة فارغة بعد التحميل، قد تكون هناك مشكلة
        if (adminsList.isEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يوجد أدمن في النظام'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('خطأ: لم يتم العثور على جلسة تسجيل الدخول'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('خطأ في تحميل الإدمن: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الإدمن: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterAdmins(String query) {
    final filtered = admins.where((admin) {
      final nameMatch = (admin['fullName'] ?? admin['username'] ?? '').toString().contains(query);
      final phoneMatch = (admin['mobile'] ?? '').toString().contains(query);
      return nameMatch || phoneMatch;
    }).toList();

    setState(() => filteredAdmins = filtered);
  }

  void _addAdmin(Admin admin) {
    // إعادة تحميل القائمة بعد إضافة أدمن
    _loadAdmins();
  }

  Future<void> _editAdmin(int index) async {
    final adminData = filteredAdmins[index];
    final admin = Admin(
      name: adminData['fullName'] ?? adminData['username'] ?? '',
      phone: adminData['mobile'] ?? '',
      email: adminData['email'],
      password: '', // لن نعرض كلمة المرور
      birthDate: '',
    );
    
    final adminId = adminData['id'] ?? adminData['objectId'];
    final username = adminData['username'] ?? '';
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAdminPage(
          admin: admin,
          adminId: adminId,
          originalUsername: username, // تمرير username الأصلي
        ),
      ),
    );
    
    if (result == true) {
      _loadAdmins();
    }
  }

  Future<void> _deleteAdmin(int index) async {
    final adminName = filteredAdmins[index]['fullName'] ?? 'الإدمن';
    bool confirm = await _showConfirmDialog(adminName);
    if (confirm) {
      try {
        final sessionToken = SharedPrefsHelper.getToken();
        final adminId = filteredAdmins[index]['objectId'] ?? filteredAdmins[index]['id'];
        
        if (sessionToken != null && sessionToken.isNotEmpty && adminId != null) {
          final result = await UserAPI.deleteAdmin(sessionToken, adminId);
          if (!result.containsKey('error')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حذف الإدمن بنجاح'), backgroundColor: Colors.green)
            );
            _loadAdmins();
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
            content: Text("هل تريد حذف الادمن ($name)؟"),
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
                          "إدارة الادمن",
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
                      // 👈 هنا حل الخطأ
                      color: Colors.transparent,
                      child: TextField(
                        controller: searchController,
                        onChanged: _filterAdmins,
                        decoration: InputDecoration(
                          hintText: "ابحث باسم الادمن أو رقم الموبايل...",
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
                        : filteredAdmins.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا يوجد إدمن',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredAdmins.length,
                                itemBuilder: (context, index) {
                                  final admin = filteredAdmins[index];
                                  final adminName = admin['fullName'] ?? admin['username'] ?? 'بدون اسم';
                                  final adminPhone = admin['mobile'] ?? 'بدون رقم';
                                  
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
                                                  adminName,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  "هاتف: $adminPhone",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54),
                                                ),
                                                if (admin['email'] != null && admin['email']!.isNotEmpty)
                                                  Text(
                                                    "بريد: ${admin['email']}",
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (SharedPrefsHelper.isSuperAdmin())
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      color: Colors.blue),
                                                  onPressed: () => _editAdmin(index),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.redAccent),
                                                  onPressed: () => _deleteAdmin(index),
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

      // 🔹 زر الإضافة - فقط لـ SuperAdmin
      floatingActionButton: SharedPrefsHelper.isSuperAdmin()
          ? FloatingActionButton(
              backgroundColor: AppColors.skyBlue,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAdminPage()),
                );
                // إذا تمت الإضافة بنجاح، أعد تحميل القائمة
                if (result == true) {
                  _loadAdmins();
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
