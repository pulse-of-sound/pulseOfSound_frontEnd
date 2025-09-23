import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import 'addSpecialistScreen.dart';
import 'editSpecialistScreen.dart';
import 'modelSpecialists.dart';

class SpecialistsPage extends StatefulWidget {
  const SpecialistsPage({super.key});

  @override
  State<SpecialistsPage> createState() => _SpecialistsPageState();
}

class _SpecialistsPageState extends State<SpecialistsPage> {
  List<Specialist> specialists = [
    Specialist(name: "أ. ليلى", age: "30", phone: "0988888888"),
    Specialist(name: "أ. خالد", age: "35", phone: "0997777777"),
  ];

  // إضافة أخصائي جديد
  void _addSpecialist(Specialist specialist) {
    setState(() {
      specialists.add(specialist);
    });
  }

  // تعديل بيانات الأخصائي
  void _editSpecialist(int index, Specialist specialist) {
    setState(() {
      specialists[index] = specialist;
    });
  }

  // حذف أخصائي
  void _deleteSpecialist(int index) {
    setState(() {
      specialists.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الأخصائيين"),
        centerTitle: true,
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: specialists.length,
          itemBuilder: (context, index) {
            final specialist = specialists[index];
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
                          specialist.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditSpecialistPage(
                                  specialist: specialist,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteSpecialist(index);
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
                        Text("العمر: ${specialist.age}"),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // الهاتف
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text("الهاتف: ${specialist.phone}"),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.skyBlue,
        onPressed: () async {
          final newSpecialist = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSpecialistPage()),
          );
          if (newSpecialist != null && newSpecialist is Specialist) {
            _addSpecialist(newSpecialist);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
