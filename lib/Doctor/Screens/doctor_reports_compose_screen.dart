import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../utils/reports_prefs.dart';

class DoctorReportsComposeScreen extends StatefulWidget {
  final String parentId;
  final String parentName;
  const DoctorReportsComposeScreen({
    super.key,
    required this.parentId,
    required this.parentName,
  });

  @override
  State<DoctorReportsComposeScreen> createState() =>
      _DoctorReportsComposeScreenState();
}

class _DoctorReportsComposeScreenState
    extends State<DoctorReportsComposeScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _saveReport() async {
    if (_controller.text.trim().isEmpty) return;
    await DoctorReportsPrefs.addReport(
        widget.parentId, widget.parentName, _controller.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تقرير ${widget.parentName}",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.skyBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _controller,
            maxLines: 12,
            decoration: const InputDecoration(
              hintText: "اكتب ملاحظاتك حول الجلسة...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.skyBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
            ),
            child: const Text("إرسال التقرير", style: TextStyle(fontSize: 16)),
          ),
        ]),
      ),
    );
  }
}
