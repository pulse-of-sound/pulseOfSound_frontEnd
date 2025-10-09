import 'package:flutter/material.dart';
import 'modelDoctor.dart';

class EditDoctorPage extends StatefulWidget {
  final Doctor doctor;
  const EditDoctorPage({super.key, required this.doctor});

  @override
  State<EditDoctorPage> createState() => _EditDoctorPageState();
}

class _EditDoctorPageState extends State<EditDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController birthDateCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController passwordCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController certificatesCtrl;
  late TextEditingController experienceCtrl;
  late TextEditingController workplaceCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.doctor.name);
    birthDateCtrl = TextEditingController(text: widget.doctor.birthDate ?? "");
    phoneCtrl = TextEditingController(text: widget.doctor.phone);
    passwordCtrl = TextEditingController(text: widget.doctor.password);
    emailCtrl = TextEditingController(text: widget.doctor.email ?? "");
    certificatesCtrl =
        TextEditingController(text: widget.doctor.certificates ?? "");
    experienceCtrl =
        TextEditingController(text: widget.doctor.experience ?? "");
    workplaceCtrl = TextEditingController(text: widget.doctor.workplace ?? "");
  }

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
      appBar: AppBar(title: const Text("تعديل الطبيب"), centerTitle: true),
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
                        final updated = Doctor(
                          name: nameCtrl.text,
                          birthDate: birthDateCtrl.text,
                          phone: phoneCtrl.text,
                          password: passwordCtrl.text,
                          email: emailCtrl.text,
                          certificates: certificatesCtrl.text,
                          experience: experienceCtrl.text,
                          workplace: workplaceCtrl.text,
                        );
                        Navigator.pop(context, updated);
                      }
                    },
                    child: const Text("حفظ التعديلات"),
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
