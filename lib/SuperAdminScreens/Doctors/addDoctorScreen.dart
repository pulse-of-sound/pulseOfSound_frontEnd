import 'package:flutter/material.dart';

import 'modelDoctor.dart';

class AddDoctorPage extends StatefulWidget {
  const AddDoctorPage({super.key});

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final certificatesCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final workplaceCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة طبيب جديد"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField("الاسم الكامل", nameCtrl),
              _buildField("العمر", ageCtrl, keyboard: TextInputType.number),
              _buildField("رقم الموبايل", phoneCtrl,
                  keyboard: TextInputType.phone),
              _buildField("البريد الإلكتروني", emailCtrl,
                  keyboard: TextInputType.emailAddress),
              _buildField("كلمة المرور", passwordCtrl, obscure: true),
              _buildField("الشهادات", certificatesCtrl),
              _buildField("سنوات الخبرة", experienceCtrl,
                  keyboard: TextInputType.number),
              _buildField("مكان العمل", workplaceCtrl),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final doctor = Doctor(
                    name: nameCtrl.text,
                    age: ageCtrl.text,
                    phone: phoneCtrl.text,
                    email: emailCtrl.text,
                    password: passwordCtrl.text,
                    certificates: certificatesCtrl.text,
                    experience: experienceCtrl.text,
                    workplace: workplaceCtrl.text,
                  );
                  Navigator.pop(context, doctor);
                },
                child: const Text("إضافة"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool obscure = false, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "الرجاء إدخال $label" : null,
      ),
    );
  }
}
