import 'package:flutter/material.dart';

import 'modelAdmin.dart';

class EditAdminPage extends StatefulWidget {
  final Admin admin;

  const EditAdminPage({super.key, required this.admin});

  @override
  State<EditAdminPage> createState() => _EditAdminPageState();
}

class _EditAdminPageState extends State<EditAdminPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.admin.name);
    phoneController = TextEditingController(text: widget.admin.phone);
    emailController = TextEditingController(text: widget.admin.email);
    passwordController = TextEditingController(text: widget.admin.password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("تعديل بيانات الأدمن"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildField("الاسم الكامل", nameController),
            const SizedBox(height: 15),
            _buildField("رقم الموبايل", phoneController,
                keyboard: TextInputType.phone),
            const SizedBox(height: 15),
            _buildField("البريد الإلكتروني", emailController,
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: 15),
            _buildField("كلمة المرور", passwordController, obscure: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updated = Admin(
                  name: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  password: passwordController.text,
                );
                Navigator.pop(context, updated);
              },
              child: const Text("حفظ التعديلات"),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("حذف الأدمن"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool obscure = false, TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
