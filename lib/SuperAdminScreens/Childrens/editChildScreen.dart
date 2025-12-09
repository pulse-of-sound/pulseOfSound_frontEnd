import 'package:flutter/material.dart';
import 'modelChild.dart';
import '../../api/child_api.dart';
import '../../utils/shared_pref_helper.dart';

class EditChildPage extends StatefulWidget {
  final Child child;
  final String? childId; // ID من API
  const EditChildPage({super.key, required this.child, this.childId});

  @override
  State<EditChildPage> createState() => _EditChildPageState();
}

class _EditChildPageState extends State<EditChildPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController birthDateController;
  late TextEditingController parentPhoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.child.name);
    birthDateController = TextEditingController(text: widget.child.birthDate);
    parentPhoneController =
        TextEditingController(text: widget.child.parentPhone);
  }

  @override
  void dispose() {
    nameController.dispose();
    birthDateController.dispose();
    parentPhoneController.dispose();
    super.dispose();
  }

  Future<void> _updateChild() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.childId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('معرف الطفل غير موجود'))
        );
        setState(() => _isLoading = false);
        return;
      }

      // تحويل تاريخ الميلاد من DD/MM/YYYY إلى YYYY-MM-DD
      String? birthdate;
      if (birthDateController.text.isNotEmpty) {
        try {
          final parts = birthDateController.text.split('/');
          if (parts.length == 3) {
            birthdate = "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
          }
        } catch (e) {
          print("خطأ في تحويل التاريخ: $e");
        }
      }

      final result = await ChildProfileAPI.createOrUpdateChildProfile(
        childId: widget.childId!,
        name: nameController.text.trim(),
        birthdate: birthdate,
        // يمكن إضافة حقول أخرى إذا كانت متوفرة في النموذج
      );

      setState(() => _isLoading = false);

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث بيانات الطفل بنجاح'), backgroundColor: Colors.green)
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
      initialDate: DateTime(2018, 1, 1),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
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

          // المحتوى
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // شريط علوي فيه زر رجوع والعنوان
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "تعديل بيانات الطفل",
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
                    const SizedBox(height: 25),

                    _buildField("اسم الطفل", nameController, required: true),
                    _buildDateField("تاريخ الميلاد", birthDateController),
                    _buildField("هاتف ولي الأمر", parentPhoneController,
                        required: true, keyboard: TextInputType.phone),
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
                      onPressed: _isLoading ? null : _updateChild,
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
                    const SizedBox(height: 14),
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
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: _pickBirthDate,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon:
              const Icon(Icons.calendar_month, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide:
                  const BorderSide(color: Colors.blueAccent, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool required = false, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide:
                  const BorderSide(color: Colors.blueAccent, width: 1.5)),
        ),
        validator: required
            ? (value) =>
                (value == null || value.isEmpty) ? "الرجاء إدخال $label" : null
            : null,
      ),
    );
  }
}
