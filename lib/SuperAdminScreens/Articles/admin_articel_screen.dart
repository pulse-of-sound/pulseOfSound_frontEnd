import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/research_api.dart';
import '../../utils/api_helpers.dart';

class AdminReviewArticlesScreen extends StatefulWidget {
  const AdminReviewArticlesScreen({super.key});

  @override
  State<AdminReviewArticlesScreen> createState() =>
      _AdminReviewArticlesScreenState();
}

class _AdminReviewArticlesScreenState extends State<AdminReviewArticlesScreen> {
  List<Map<String, dynamic>> pending = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => isLoading = true);
    try {
      final token = await APIHelpers.getSessionToken();
      final list = await ResearchPostsAPI.getPendingResearchPosts(sessionToken: token);
      setState(() => pending = list);
    } catch (e) {
      if (mounted) APIHelpers.showErrorDialog(context, "حدث خطأ أثناء تحميل المقالات: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _approve(String postId) async {
    try {
      final token = await APIHelpers.getSessionToken();
      final result = await ResearchPostsAPI.approveOrRejectPost(
        sessionToken: token,
        postId: postId,
        action: 'publish',
      );

      if (result.containsKey('error')) {
        if (mounted) APIHelpers.showErrorDialog(context, result['error']);
      } else {
        _loadPending();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(" تمت الموافقة على المقال")),
          );
        }
      }
    } catch (e) {
       if (mounted) APIHelpers.showErrorDialog(context, "حدث خطأ: $e");
    }
  }

  Future<void> _reject(String postId) async {
    final TextEditingController reasonController = TextEditingController();
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("رفض المقال"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: "سبب الرفض (اختياري)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("رفض", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await APIHelpers.getSessionToken();
      final result = await ResearchPostsAPI.approveOrRejectPost(
        sessionToken: token,
        postId: postId,
        action: 'reject',
        rejectionReason: reasonController.text.trim(),
      );

      if (result.containsKey('error')) {
        if (mounted) APIHelpers.showErrorDialog(context, result['error']);
      } else {
        _loadPending();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(" تم رفض المقال")),
          );
        }
      }
    } catch (e) {
       if (mounted) APIHelpers.showErrorDialog(context, "حدث خطأ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadPending,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Admin.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : pending.isEmpty
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
                      padding: const EdgeInsets.only(top: 10, bottom: 16),
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
                                const SizedBox(height: 4),
                                Text(
                                  "الكاتب: ${a["author"]["name"]}",
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                Text(
                                  "الفئة: ${a["category"]}",
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                const Divider(),
                                Text(
                                  a["body"],
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _approve(a["post_id"]),
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
                                      onPressed: () => _reject(a["post_id"]),
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
