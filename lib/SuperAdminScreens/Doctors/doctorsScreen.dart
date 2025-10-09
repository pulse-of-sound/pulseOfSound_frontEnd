import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Colors/colors.dart';

import 'addDoctorScreen.dart';

import 'editDoctorScreen.dart';
import 'modelDoctor.dart';

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  List<Doctor> doctors = [
    Doctor(
      name: "د. أحمد",
      birthDate: "10/3/1985",
      phone: "0999999999",
      password: "1234",
      email: "ahmad@mail.com",
      certificates: "دكتوراه في طب الأذن",
      experience: "10 سنوات",
      workplace: "مشفى السلام",
    ),
    Doctor(
      name: "د. أحمد",
      birthDate: "10/3/1985",
      phone: "0999999999",
      password: "1234",
      email: "ahmad@mail.com",
      certificates: "دكتوراه في طب الأذن",
      experience: "10 سنوات",
      workplace: "مشفى السلام",
    ),
  ];

  List<Doctor> filteredDoctors = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors;
  }

  void _filterDoctors(String query) {
    final filtered = doctors.where((doctor) {
      final nameMatch = doctor.name.contains(query);
      final phoneMatch = doctor.phone.contains(query);
      return nameMatch || phoneMatch;
    }).toList();

    setState(() => filteredDoctors = filtered);
  }

  void _addDoctor(Doctor doctor) {
    setState(() {
      doctors.add(doctor);
      filteredDoctors = doctors;
    });
  }

  void _editDoctor(int index, Doctor updated) {
    setState(() {
      doctors[index] = updated;
      filteredDoctors = doctors;
    });
  }

  void _deleteDoctor(int index) async {
    bool confirm = await _showConfirmDialog(doctors[index].name);
    if (confirm) {
      setState(() {
        doctors.removeAt(index);
        filteredDoctors = doctors;
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
      // 🔹 الخلفية
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

                // 🔹 شريط علوي
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

// 🔹 البحث
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      // 👈 هنا حل الخطأ
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

                  // 🔹 القائمة
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = filteredDoctors[index];
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
                                        doctor.name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "هاتف: ${doctor.phone}",
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54),
                                      ),
                                      if (doctor.birthDate != null &&
                                          doctor.birthDate!.isNotEmpty)
                                        Text(
                                          "تاريخ الميلاد: ${doctor.birthDate}",
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
                                                EditDoctorPage(doctor: doctor),
                                          ),
                                        );
                                        if (updated != null &&
                                            updated is Doctor) {
                                          _editDoctor(index, updated);
                                        }
                                      },
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

      // 🔹 زر الإضافة
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.skyBlue,
        onPressed: () async {
          final newDoctor = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDoctorPage()),
          );
          if (newDoctor != null) _addDoctor(newDoctor);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
