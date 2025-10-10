import 'package:flutter/material.dart';
import 'package:pulse_of_sound/SuperAdminScreens/Admin/modelAdmin.dart';

class AddAdminPage extends StatefulWidget {
  const AddAdminPage({super.key});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final birthDateCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

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
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Admin.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // شريط العنوان
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "إضافة ادمن جديد",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildField("الاسم الكامل", nameCtrl, required: true),
                    _buildDateField("تاريخ الميلاد", birthDateCtrl),
                    _buildField("رقم الموبايل", phoneCtrl,
                        required: true, keyboard: TextInputType.phone),
                    _buildField("كلمة المرور", passwordCtrl,
                        required: true, obscure: true),
                    _buildField("البريد الإلكتروني", emailCtrl,
                        keyboard: TextInputType.emailAddress),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20), // حواف مدورة أكتر
                        ),
                        elevation: 6,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final doctor = Admin(
                            name: nameCtrl.text,
                            birthDate: birthDateCtrl.text,
                            phone: phoneCtrl.text,
                            password: passwordCtrl.text,
                            email: emailCtrl.text,
                          );
                          Navigator.pop(context, doctor);
                        }
                      },
                      child: const Text(
                        "إضافة الأدمن",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: _inputBoxDecoration(),
        child: TextFormField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(color: Colors.black87),
          onTap: _pickBirthDate,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white.withOpacity(0.85),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.blueAccent, width: 1.5)),
            suffixIcon:
                const Icon(Icons.calendar_today, color: Colors.blueAccent),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool required = false,
      bool obscure = false,
      TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: _inputBoxDecoration(),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white.withOpacity(0.85),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: required
              ? (value) => (value == null || value.isEmpty)
                  ? "الرجاء إدخال $label"
                  : null
              : null,
        ),
      ),
    );
  }

  BoxDecoration _inputBoxDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 6,
          offset: const Offset(2, 3),
        ),
      ],
    );
  }
}
