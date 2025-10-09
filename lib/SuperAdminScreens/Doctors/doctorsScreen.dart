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
  ];

  void _addDoctor(Doctor doctor) {
    setState(() => doctors.add(doctor));
  }

  void _editDoctor(int index, Doctor updated) {
    setState(() => doctors[index] = updated);
  }

  void _deleteDoctor(int index) {
    setState(() => doctors.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية ثابتة
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Admin.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // المحتوى
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Card(
                color: Colors.white.withOpacity(0.85),
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.skyBlue,
                    radius: 26,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    doctor.name,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "هاتف: ${doctor.phone}",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditDoctorPage(doctor: doctor),
                            ),
                          );
                          if (updated != null && updated is Doctor) {
                            _editDoctor(index, updated);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteDoctor(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
