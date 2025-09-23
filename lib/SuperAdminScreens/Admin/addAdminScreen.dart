import 'package:flutter/material.dart';

import 'modelAdmin.dart';

class AddAdminPage extends StatelessWidget {
  const AddAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("إضافة أدمن جديد"), centerTitle: true),
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
                final newAdmin = Admin(
                  name: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  password: passwordController.text,
                );
                Navigator.pop(context, newAdmin);
              },
              child: const Text("إضافة"),
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
