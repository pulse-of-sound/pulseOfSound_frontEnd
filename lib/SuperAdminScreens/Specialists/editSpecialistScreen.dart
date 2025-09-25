import 'package:flutter/material.dart';
import 'modelSpecialists.dart';

class EditSpecialistPage extends StatefulWidget {
  final Specialist specialist;

  const EditSpecialistPage({super.key, required this.specialist});

  @override
  State<EditSpecialistPage> createState() => _EditSpecialistPageState();
}

class _EditSpecialistPageState extends State<EditSpecialistPage> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.specialist.name);
    ageController = TextEditingController(text: widget.specialist.age);
    phoneController = TextEditingController(text: widget.specialist.phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("تعديل بيانات الأخصائي"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildField("الاسم الكامل", nameController),
            const SizedBox(height: 15),
            _buildField("العمر", ageController, keyboard: TextInputType.number),
            const SizedBox(height: 15),
            _buildField("رقم الموبايل", phoneController,
                keyboard: TextInputType.phone),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updated = Specialist(
                  name: nameController.text,
                  age: ageController.text,
                  phone: phoneController.text,
                );
                Navigator.pop(context, updated);
              },
              child: const Text("حفظ التعديلات"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
