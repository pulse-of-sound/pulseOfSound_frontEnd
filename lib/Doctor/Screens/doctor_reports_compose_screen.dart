import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/reports_api.dart';
import '../../utils/api_helpers.dart';

class DoctorReportsComposeScreen extends StatefulWidget {
  final String parentId;
  final String parentName;
  final String childName;
  final String childId;
  final String appointmentId;

  const DoctorReportsComposeScreen({
    super.key,
    required this.parentId,
    required this.parentName,
    required this.childName,
    required this.childId,
    required this.appointmentId,
  });

  @override
  State<DoctorReportsComposeScreen> createState() =>
      _DoctorReportsComposeScreenState();
}

class _DoctorReportsComposeScreenState
    extends State<DoctorReportsComposeScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  bool isSubmitting = false;

  Future<void> _saveReport() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
       APIHelpers.showErrorDialog(context, "الرجاء كتابة محتوى التقرير");
       return;
    }
    
    setState(() => isSubmitting = true);
    
    try {
      final token = await APIHelpers.getSessionToken();
      print("Submitting report for appointment: ${widget.appointmentId}");
      print("Child ID: '${widget.childId}' (isEmpty: ${widget.childId.isEmpty})");
      final result = await ReportsAPI.submitReport(
        sessionToken: token,
        appointmentId: widget.appointmentId,
        content: content,
        summary: _summaryController.text.trim(),
        childId: widget.childId.isNotEmpty ? widget.childId : null,
      );

      if (mounted) {
        if (!result.containsKey('error') && !result.containsKey('code')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال التقرير بنجاح'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          final errorMsg = result['error'] ?? result['message'] ?? "فشل إرسال التقرير";
          APIHelpers.showErrorDialog(context, errorMsg);
        }
      }
    } catch (e) {
      if (mounted) APIHelpers.showErrorDialog(context, 'حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("كتابة تقرير الجلسة",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/doctorsBackground.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 20),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("معلومات الجلسة", 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.skyBlue)),
                        const Divider(height: 20, thickness: 1),
                        Row(
                          children: [
                            const Icon(Icons.person, color: AppColors.skyBlue, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text("ولي الأمر: ${widget.parentName}", 
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.pink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.child_care, color: AppColors.pink, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text("الطفل: ${widget.childName}", 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.pink)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _summaryController,
                  decoration: InputDecoration(
                    labelText: "ملخص الجلسة (اختياري)",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: "اكتب تفاصيل التقرير والملاحظات هنا...",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),
                if (isSubmitting)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  ElevatedButton(
                    onPressed: _saveReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.skyBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    child: const Text("إرسال التقرير النهائي", 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
