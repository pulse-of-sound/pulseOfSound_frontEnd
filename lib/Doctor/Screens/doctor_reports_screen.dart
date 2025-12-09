import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Colors/colors.dart';

class DoctorReportsScreen extends StatefulWidget {
  final String parentId; // لتحديد التقارير الخاصة بولي أمر معين
  const DoctorReportsScreen(
      {super.key, required this.parentId, required String parentName});

  @override
  State<DoctorReportsScreen> createState() => _DoctorReportsScreenState();
}

class _DoctorReportsScreenState extends State<DoctorReportsScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("reports_${widget.parentId}");
    if (data != null) {
      setState(() {
        reports = List<Map<String, String>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _saveReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("reports_${widget.parentId}", jsonEncode(reports));
  }

  Future<void> _sendReport() async {
    if (_controller.text.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    int currentCount =
        prefs.getInt("new_reports_count_${widget.parentId}") ?? 0;
    await prefs.setInt("new_reports_count_${widget.parentId}", currentCount + 1);

    final newReport = {
      "text": _controller.text.trim(),
      "date": DateTime.now().toString().substring(0, 16),
    };

    setState(() {
      reports.insert(0, newReport);
    });

    _controller.clear();
    await _saveReports();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إرسال التقرير بنجاح")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/doctorsBackground.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    "التقارير الطبية",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ]),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "أدخل التقرير هنا...",
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _sendReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.skyBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text("إرسال التقرير"),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final r = reports[index];
                    return Card(
                      color: Colors.white.withOpacity(0.9),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.description,
                            color: AppColors.skyBlue),
                        title: Text(
                          r["text"]!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text("تاريخ الإرسال: ${r["date"]!}"),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
