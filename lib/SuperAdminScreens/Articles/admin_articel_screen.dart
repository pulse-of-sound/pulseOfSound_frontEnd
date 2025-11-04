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
      const SnackBar(content: Text(" تمت الموافقة على المقال")),
    );
  }

  Future<void> _reject(int i) async {
    await DoctorArticlesPrefs.rejectArticle(i);
    _loadPending();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(" تم رفض المقال")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "مراجعة المقالات",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // خلفية شفافة مثل باقي شاشات الأدمن
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: pending.isEmpty
                  ? const Center(
                      child: Text(
                        "لا توجد مقالات للمراجعة",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(top: topPadding, bottom: 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: pending.length,
                      itemBuilder: (context, index) {
                        final a = pending[index];
                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a["title"],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.skyBlue,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  a["content"],
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _approve(index),
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text("موافقة"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      onPressed: () => _reject(index),
                                      icon: const Icon(Icons.cancel),
                                      label: const Text("رفض"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
