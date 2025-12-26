import 'package:flutter/material.dart';
import 'modelDoctor.dart';
import '../../api/user_api.dart';
import '../../utils/shared_pref_helper.dart';

class EditDoctorPage extends StatefulWidget {
  final Doctor doctor;
  final String? doctorId; 
  final String? originalUsername; 
  const EditDoctorPage({super.key, required this.doctor, this.doctorId, this.originalUsername});

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
  bool _isLoading = false;

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

  @override
  void dispose() {
    nameCtrl.dispose();
    birthDateCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    emailCtrl.dispose();
    certificatesCtrl.dispose();
    experienceCtrl.dispose();
    workplaceCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final sessionToken = SharedPrefsHelper.getToken();
      if (sessionToken == null || sessionToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على جلسة'))
        );
        setState(() => _isLoading = false);
        return;
      }

      
      String username = widget.originalUsername ?? 
          widget.doctor.name.trim().replaceAll(' ', '_').toLowerCase();
      
      final result = await UserAPI.addEditDoctor(
        sessionToken,
        fullName: nameCtrl.text.trim(),
        username: username,
        password: passwordCtrl.text.isNotEmpty ? passwordCtrl.text : "temp123", 
        mobile: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
      );

      setState(() => _isLoading = false);

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث بيانات الطبيب بنجاح'), backgroundColor: Colors.green)
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red)
      );
    }
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
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "تعديل بيانات الطبيب",
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
                    _buildField("الشهادات", certificatesCtrl),
                    _buildField("سنوات الخبرة", experienceCtrl),
                    _buildField("مكان العمل", workplaceCtrl),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                      ),
                      onPressed: _isLoading ? null : _updateDoctor,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "حفظ التعديلات",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
          onTap: _pickBirthDate,
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
                borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
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
                borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.white, width: 1.5)),
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
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 6,
          offset: Offset(2, 3),
        ),
      ],
    );
  }
}
