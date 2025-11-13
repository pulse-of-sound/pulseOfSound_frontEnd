import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Levels/utils/child_progress_prefs.dart';

import '../../Colors/colors.dart';

class ParentProfileDetailsScreen extends StatefulWidget {
  final String parentId; // رقم أو هوية ولي الأمر (من المحادثة)
  const ParentProfileDetailsScreen({super.key, required this.parentId});

  @override
  State<ParentProfileDetailsScreen> createState() =>
      _ParentProfileDetailsScreenState();
}

class _ParentProfileDetailsScreenState
    extends State<ParentProfileDetailsScreen> {
  Map<String, String?> profile = {};
  List<Map<String, dynamic>> evaluations = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadEvaluations();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      profile = {
        "name": prefs.getString("name"),
        "fatherName": prefs.getString("fatherName"),
        "birthDate": prefs.getString("birthDate"),
        "gender": prefs.getString("gender"),
        "healthStatus": prefs.getString("healthStatus"),
        "image": prefs.getString("profileImage"),
      };
    });
  }

  Future<void> _loadEvaluations() async {
    final data = await ChildProgressPrefs.loadEvaluations();
    setState(() => evaluations = data);
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = profile["image"];
    return Scaffold(
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
          SafeArea(
            child: Column(
              children: [
                // AppBar شفاف
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "معلومات الطفل ووليّ الأمر",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 15),

                // صورة الطفل
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white.withOpacity(0.8),
                  backgroundImage:
                      (imagePath != null && File(imagePath).existsSync())
                          ? FileImage(File(imagePath))
                          : const AssetImage("images/resultSuccess1.jpg")
                              as ImageProvider,
                ),
                const SizedBox(height: 10),

                // المعلومات الأساسية
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(" الاسم: ${profile["name"] ?? "غير محدد"}",
                              textAlign: TextAlign.right),
                          Text(
                              " اسم الأب: ${profile["fatherName"] ?? "غير محدد"}",
                              textAlign: TextAlign.right),
                          Text(
                              " تاريخ الميلاد: ${profile["birthDate"] ?? "غير محدد"}",
                              textAlign: TextAlign.right),
                          Text(" الجنس: ${profile["gender"] ?? "غير محدد"}",
                              textAlign: TextAlign.right),
                          Text(
                              " الحالة الصحية: ${profile["healthStatus"] ?? "غير محددة"}",
                              textAlign: TextAlign.right),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // تقييمات الطفل
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          " تقييمات الطفل:",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: evaluations.isEmpty
                              ? const Center(
                                  child: Text(
                                    "لا توجد تقييمات بعد.",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: evaluations.length,
                                  itemBuilder: (context, index) {
                                    final e = evaluations[index];
                                    return Card(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        leading: const Icon(Icons.grade,
                                            color: AppColors.skyBlue),
                                        title: Text(
                                            "المجموعة: ${e["group"] ?? "غير محددة"}"),
                                        subtitle: Text(
                                            "النتيجة: ${e["score"] ?? 0}/100 — التاريخ: ${e["date"] ?? ""}"),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
