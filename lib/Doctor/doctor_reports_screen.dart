import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import 'utils/doctor_wallet_prefs.dart';

class DoctorReportsScreen extends StatefulWidget {
  const DoctorReportsScreen({super.key});

  @override
  State<DoctorReportsScreen> createState() => _DoctorReportsScreenState();
}

class _DoctorReportsScreenState extends State<DoctorReportsScreen> {
  final TextEditingController reportController = TextEditingController();
  final List<Map<String, String>> reports = [];

  void _submitReport() {
    if (reportController.text.trim().isEmpty) return;
    setState(() {
      reports.add({
        "text": reportController.text.trim(),
        "date": DateTime.now().toString(),
      });
      reportController.clear();
    });
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
                        "التقارير الطبية",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: reportController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "أدخل تقريرك الطبي هنا...",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.skyBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text("إرسال التقرير"),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final r = reports[index];
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        child: ListTile(
                          title: Text(r["text"]!),
                          subtitle: Text(r["date"]!),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
