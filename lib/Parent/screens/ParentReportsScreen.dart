import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../Doctor/utils/reports_prefs.dart';

class ParentReportsScreen extends StatefulWidget {
  final String parentId;
  const ParentReportsScreen({super.key, required this.parentId});

  @override
  State<ParentReportsScreen> createState() => _ParentReportsScreenState();
}

class _ParentReportsScreenState extends State<ParentReportsScreen> {
  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final data = await DoctorReportsPrefs.loadReports();
    // تصفية التقارير حسب الـ parentId
    setState(() {
      reports = data.where((r) => r["parentId"] == widget.parentId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "تقاريري الطبية",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/chat_Background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: reports.isEmpty
                  ? const Center(
                      child: Text(
                        "لا توجد تقارير بعد",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final r = reports[index];
                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long,
                                color: AppColors.pink),
                            title: Text(
                              r["content"] ?? "—",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              "من الطبيب: ${r["doctorName"] ?? "غير معروف"}\n"
                              "تاريخ الإرسال: ${r["time"]?.toString().substring(0, 16) ?? "--"}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
