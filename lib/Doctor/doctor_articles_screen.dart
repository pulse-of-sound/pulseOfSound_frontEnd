import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import 'utils/doctor_articles_prefs.dart';

class DoctorArticlesScreen extends StatefulWidget {
  const DoctorArticlesScreen({super.key});

  @override
  State<DoctorArticlesScreen> createState() => _DoctorArticlesScreenState();
}

class _DoctorArticlesScreenState extends State<DoctorArticlesScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<Map<String, dynamic>> myArticles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    final articles = await DoctorArticlesPrefs.loadArticles();
    setState(() => myArticles = articles);
  }

  Future<void> _submitArticle() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    await DoctorArticlesPrefs.addArticle({
      "title": title,
      "content": content,
      "status": "pending",
      "date": DateTime.now().toIso8601String(),
    });
    titleController.clear();
    contentController.clear();
    _loadArticles();
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
                        "مقالاتي",
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
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "عنوان المقال",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "محتوى المقال...",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _submitArticle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.skyBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text("إرسال المقال"),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: myArticles.length,
                    itemBuilder: (context, index) {
                      final a = myArticles[index];
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          title: Text(a["title"]),
                          subtitle: Text(
                            a["status"] == "pending"
                                ? "قيد المراجعة"
                                : a["status"] == "approved"
                                    ? "تمت الموافقة"
                                    : "مرفوض",
                            style: TextStyle(
                              color: a["status"] == "approved"
                                  ? Colors.green
                                  : a["status"] == "rejected"
                                      ? Colors.red
                                      : Colors.orangeAccent,
                            ),
                          ),
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
