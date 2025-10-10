import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Colors/colors.dart';
import 'package:pulse_of_sound/SuperAdminScreens/Admin/modelAdmin.dart';

import 'addAdminScreen.dart';
import 'editAdminScreen.dart';

class Adminscreen extends StatefulWidget {
  const Adminscreen({super.key});

  @override
  State<Adminscreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<Adminscreen> {
  List<Admin> admins = [
    Admin(
      name: "مدير النظام",
      birthDate: "10/3/1985",
      phone: "0999999999",
      password: "1234",
      email: "ahmad@mail.com",
    ),
    Admin(
      name: "مدير النظام",
      birthDate: "10/3/1985",
      phone: "0999999999",
      password: "1234",
      email: "ahmad@mail.com",
    ),
  ];

  List<Admin> filteredAdmins = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredAdmins = admins;
  }

  void _filterAdmins(String query) {
    final filtered = admins.where((admin) {
      final nameMatch = admin.name.contains(query);
      final phoneMatch = admin.phone.contains(query);
      return nameMatch || phoneMatch;
    }).toList();

    setState(() => filteredAdmins = filtered);
  }

  void _addAdmin(Admin admin) {
    setState(() {
      admins.add(admin);
      filteredAdmins = admins;
    });
  }

  void _editAdmin(int index, Admin updated) {
    setState(() {
      admins[index] = updated;
      filteredAdmins = admins;
    });
  }

  void _deleteAdmin(int index) async {
    bool confirm = await _showConfirmDialog(admins[index].name);
    if (confirm) {
      setState(() {
        admins.removeAt(index);
        filteredAdmins = admins;
      });
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
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredAdmins.length,
                      itemBuilder: (context, index) {
                        final admin = filteredAdmins[index];
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
                                        admin.name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "هاتف: ${admin.phone}",
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54),
                                      ),
                                      if (admin.birthDate != null &&
                                          admin.birthDate!.isNotEmpty)
                                        Text(
                                          "تاريخ الميلاد: ${admin.birthDate}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blueAccent),
                                      onPressed: () async {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditAdminPage(admin: admin),
                                          ),
                                        );
                                        if (updated != null &&
                                            updated is Admin) {
                                          _editAdmin(index, updated);
                                        }
                                      },
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

      // 🔹 زر الإضافة
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.skyBlue,
        onPressed: () async {
          final newDoctor = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAdminPage()),
          );
          if (newDoctor != null) _addAdmin(newDoctor);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
