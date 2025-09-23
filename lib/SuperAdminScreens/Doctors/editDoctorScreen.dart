import 'package:flutter/material.dart';

import 'modelDoctor.dart';

class EditDoctorPage extends StatefulWidget {
  final Doctor doctor;
  const EditDoctorPage({
    super.key,
    required this.doctor,
  });

  @override
  State<EditDoctorPage> createState() => _EditDoctorPageState();
}

class _EditDoctorPageState extends State<EditDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController ageCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController passwordCtrl;
  late TextEditingController certificatesCtrl;
  late TextEditingController experienceCtrl;
  late TextEditingController workplaceCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.doctor.name);
    ageCtrl = TextEditingController(text: widget.doctor.age);
    phoneCtrl = TextEditingController(text: widget.doctor.phone);
    emailCtrl = TextEditingController(text: widget.doctor.email);
    passwordCtrl = TextEditingController(text: widget.doctor.password);
    certificatesCtrl = TextEditingController(text: widget.doctor.certificates);
    experienceCtrl = TextEditingController(text: widget.doctor.experience);
    workplaceCtrl = TextEditingController(text: widget.doctor.workplace);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("تعديل بيانات الطبيب"), centerTitle: true),
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
                  final updatedDoctor = Doctor(
                    name: nameCtrl.text,
                    age: ageCtrl.text,
                    phone: phoneCtrl.text,
                    email: emailCtrl.text,
                    password: passwordCtrl.text,
                    certificates: certificatesCtrl.text,
                    experience: experienceCtrl.text,
                    workplace: workplaceCtrl.text,
                  );
                  Navigator.pop(context, updatedDoctor);
                },
                child: const Text("حفظ التعديلات"),
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
