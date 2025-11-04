import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../Doctor/utils/doctor_articles_prefs.dart';

class AdminReviewArticlesScreen extends StatefulWidget {
  const AdminReviewArticlesScreen({super.key});

  @override
  State<AdminReviewArticlesScreen> createState() =>
      _AdminReviewArticlesScreenState();
}

class _AdminReviewArticlesScreenState extends State<AdminReviewArticlesScreen> {
  List<Map<String, dynamic>> pending = [];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final list = await DoctorArticlesPrefs.loadPendingArticles();
    setState(() => pending = list);
  }

  Future<void> _approve(int i) async {
    await DoctorArticlesPrefs.approveArticle(i);
    _loadPending();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تمت الموافقة على المقال ")));
  }

  Future<void> _reject(int i) async {
    await DoctorArticlesPrefs.rejectArticle(i);
    _loadPending();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("تم رفض المقال ")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مراجعة المقالات"),
        centerTitle: true,
        backgroundColor: AppColors.pink,
      ),
      body: pending.isEmpty
          ? const Center(child: Text("لا توجد مقالات للمراجعة"))
          : ListView.builder(
              itemCount: pending.length,
              itemBuilder: (context, index) {
                final a = pending[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a["title"],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(a["content"]),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _approve(index),
                              icon: const Icon(Icons.check),
                              label: const Text("موافقة"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () => _reject(index),
                              icon: const Icon(Icons.close),
                              label: const Text("رفض"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
