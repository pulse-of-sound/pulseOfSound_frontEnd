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
      age: "40",
      phone: "0999999999",
      email: "ahmad@mail.com",
      password: "1234",
      certificates: "دكتوراه",
      experience: "10",
      workplace: "مشفى السلام",
    ),
    Doctor(
      name: "د. سارة",
      age: "35",
      phone: "0988888888",
      email: "sara@mail.com",
      password: "abcd",
      certificates: "ماجستير",
      experience: "8",
      workplace: "مركز الشفاء",
    ),
  ];

  void _addDoctor(Doctor doctor) {
    setState(() {
      doctors.add(doctor);
    });
  }

  void _editDoctor(int index, Doctor doctor) {
    setState(() {
      doctors[index] = doctor;
    });
  }

  void _deleteDoctor(int index) {
    setState(() {
      doctors.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الأطباء"), centerTitle: true),
      body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return Card(
              color: AppColors.babyBlue,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
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
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteDoctor(index);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // العمر
                    Row(
                      children: [
                        const Icon(Icons.cake, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text("العمر: ${doctor.age}"),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // الهاتف
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text("الهاتف: ${doctor.phone}"),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newDoctor = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDoctorPage()),
          );
          if (newDoctor != null) {
            _addDoctor(newDoctor);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
