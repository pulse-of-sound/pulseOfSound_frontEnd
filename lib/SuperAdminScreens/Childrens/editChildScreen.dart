import 'package:flutter/material.dart';

import 'modelChild.dart';

class EditChildPage extends StatefulWidget {
  final Child child;

  const EditChildPage({super.key, required this.child});

  @override
  State<EditChildPage> createState() => _EditChildPageState();
}

class _EditChildPageState extends State<EditChildPage> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController parentPhoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.child.name);
    ageController = TextEditingController(text: widget.child.age);
    parentPhoneController =
        TextEditingController(text: widget.child.parentPhone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("تعديل بيانات الطفل"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildField("اسم الطفل", nameController),
            const SizedBox(height: 15),
            _buildField("العمر", ageController, keyboard: TextInputType.number),
            const SizedBox(height: 15),
            _buildField("هاتف ولي الأمر", parentPhoneController,
                keyboard: TextInputType.phone),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updated = Child(
                  name: nameController.text,
                  age: ageController.text,
                  parentPhone: parentPhoneController.text,
                );
                Navigator.pop(context, updated);
              },
              child: const Text("حفظ التعديلات"),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context, null); // null = حذف
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("حذف الطفل"),
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
