import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Colors/colors.dart';
import 'package:pulse_of_sound/SuperAdminScreens/Specialists/modelSpecialists.dart';

import 'addSpecialistScreen.dart';

import 'editSpecialistScreen.dart';

class Specialistscreen extends StatefulWidget {
  const Specialistscreen({super.key});

  @override
  State<Specialistscreen> createState() => _SpecialistscreenState();
}

class _SpecialistscreenState extends State<Specialistscreen> {
  List<Specialist> specialists = [
    Specialist(
      name: "أ. أحمد",
      birthDate: "10/3/1985",
      phone: "0999999999",
      password: "1234",
      email: "ahmad@mail.com",
      certificates: "دكتوراه في الطب النفسي",
      experience: "10 سنوات",
      workplace: "مشفى السلام",
    ),
    Specialist(
      name: "أ. أحمد",
      birthDate: "10/3/1985",
      phone: "0999999999",
      password: "1234",
      email: "ahmad@mail.com",
      certificates: "دكتوراه في الطب العلاجي",
      experience: "10 سنوات",
      workplace: "مشفى السلام",
    ),
  ];

  List<Specialist> filteredSpecialists = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredSpecialists = specialists;
  }

  void _filterSpecialist(String query) {
    final filtered = specialists.where((specialist) {
      final nameMatch = specialist.name.contains(query);
      final phoneMatch = specialist.phone.contains(query);
      return nameMatch || phoneMatch;
    }).toList();

    setState(() => filteredSpecialists = filtered);
  }

  void _addSpecialist(Specialist specialist) {
    setState(() {
      specialists.add(specialist);
      filteredSpecialists = specialists;
    });
  }

  void _editSpecialist(int index, Specialist updated) {
    setState(() {
      specialists[index] = updated;
      filteredSpecialists = specialists;
    });
  }

  void _deleteSpecialist(int index) async {
    bool confirm = await _showConfirmDialog(specialists[index].name);
    if (confirm) {
      setState(() {
        specialists.removeAt(index);
        filteredSpecialists = specialists;
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
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredSpecialists.length,
                      itemBuilder: (context, index) {
                        final specialist = filteredSpecialists[index];
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
                                        specialist.name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "هاتف: ${specialist.phone}",
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54),
                                      ),
                                      if (specialist.birthDate != null &&
                                          specialist.birthDate!.isNotEmpty)
                                        Text(
                                          "تاريخ الميلاد: ${specialist.birthDate}",
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
                                            builder: (_) => EditSpecialistPage(
                                                specialist: specialist),
                                          ),
                                        );
                                        if (updated != null &&
                                            updated is Specialist) {
                                          _editSpecialist(index, updated);
                                        }
                                      },
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

      //  زر الإضافة
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.skyBlue,
        onPressed: () async {
          final newDoctor = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSpecialistPage()),
          );
          if (newDoctor != null) _addSpecialist(newDoctor);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
