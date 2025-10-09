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
  final birthDateCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final certificatesCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final workplaceCtrl = TextEditingController();

  Future<void> _pickBirthDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1980),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthDateCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة طبيب"), centerTitle: true),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildField("الاسم الكامل", nameCtrl, required: true),
                  _buildDateField("تاريخ الميلاد", birthDateCtrl),
                  _buildField("رقم الموبايل", phoneCtrl,
                      required: true, keyboard: TextInputType.phone),
                  _buildField("كلمة المرور", passwordCtrl,
                      required: true, obscure: true),
                  _buildField("البريد الإلكتروني", emailCtrl,
                      keyboard: TextInputType.emailAddress),
                  _buildField("الشهادات", certificatesCtrl),
                  _buildField("سنوات الخبرة", experienceCtrl),
                  _buildField("مكان العمل", workplaceCtrl),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final doctor = Doctor(
                          name: nameCtrl.text,
                          birthDate: birthDateCtrl.text,
                          phone: phoneCtrl.text,
                          password: passwordCtrl.text,
                          email: emailCtrl.text,
                          certificates: certificatesCtrl.text,
                          experience: experienceCtrl.text,
                          workplace: workplaceCtrl.text,
                        );
                        Navigator.pop(context, doctor);
                      }
                    },
                    child: const Text("إضافة الطبيب"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onTap: _pickBirthDate,
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool required = false,
      bool obscure = false,
      TextInputType keyboard = TextInputType.text}) {
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
        validator: required
            ? (value) =>
                (value == null || value.isEmpty) ? "الرجاء إدخال $label" : null
            : null,
      ),
    );
  }
}
