
import 'package:flutter/material.dart';

import '../api/user_api.dart';

class APITestScreen extends StatefulWidget {
  const APITestScreen({super.key});

  @override
  State<APITestScreen> createState() => _APITestScreenState();
}

class _APITestScreenState extends State<APITestScreen> {
  String sessionToken =
      "r:894e9138e77b0d351a26ed822d3ab783";
  String testLog = "اختبار APIs:\n\n";

  void addLog(String message) {
    setState(() {
      testLog += "$message\n";
    });
  }

  Future<void> testAddDoctor() async {
    addLog("🔄 جاري اختبار إضافة طبيب...");
    final result = await UserAPI.addEditDoctor(
      sessionToken,
      fullName: "د. علي احمد",
      username: "dr_ali_test",
      password: "test123456",
      mobile: "966501234567",
      email: "dr_ali@test.com",
    );

    if (result.containsKey("error")) {
      addLog("❌ خطأ: ${result["error"]}");
    } else {
      addLog("✅ تم إضافة الطبيب بنجاح: ${result["id"] ?? result["username"]}");
    }
  }

  Future<void> testGetAllDoctors() async {
    addLog("🔄 جاري جلب الأطباء...");
    final doctors = await UserAPI.getAllDoctors(sessionToken);
    if (doctors.isEmpty) {
      addLog("⚠️ لا توجد أطباء");
    } else {
      addLog("✅ عدد الأطباء: ${doctors.length}");
      for (var doc in doctors) {
        addLog("  - ${doc["fullName"] ?? doc["username"]}");
      }
    }
  }

  Future<void> testDeleteDoctor() async {
    final doctors = await UserAPI.getAllDoctors(sessionToken);
    if (doctors.isEmpty) {
      addLog("⚠️ لا توجد أطباء للحذف");
      return;
    }

    final doctorId = doctors.first["objectId"] ?? doctors.first["id"];
    addLog("🔄 جاري حذف الطبيب: $doctorId");

    final result = await UserAPI.deleteDoctor(sessionToken, doctorId);
    if (result.containsKey("error")) {
      addLog("❌ خطأ: ${result["error"]}");
    } else {
      addLog("✅ تم حذف الطبيب بنجاح");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Test Screen")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(testLog,
                    style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        color: Colors.black87)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: testAddDoctor,
                  child: const Text("إضافة طبيب"),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: testGetAllDoctors,
                  child: const Text("جلب الأطباء"),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: testDeleteDoctor,
                  child: const Text("حذف أول طبيب"),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      testLog = "تم مسح السجل\n";
                    });
                  },
                  child: const Text("مسح السجل"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
