import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'articleDetailScreen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final List<Map<String, String>> _articles = [
    {
      "title": "العناية بجهاز القوقعة",
      "description":
          "تعرف على أهم الخطوات للحفاظ على جهاز القوقعة بحالة ممتازة.",
      "image": "images/articles1.jpg",
    },
    {
      "title": "تمارين السمع للأطفال",
      "description":
          "أنشطة وتمارين تساعد الطفل على تحسين مهارات السمع بعد الزراعة.",
      "image": "images/articles2.jpg",
    },
    {
      "title": "المتابعة الطبية الدورية",
      "description": "أهمية المتابعة المنتظمة مع الطبيب بعد عملية الزراعة.",
      "image": "images/articles3.jpg",
    },
  ];

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filtered = _articles.where((article) {
      final q = _searchQuery.toLowerCase();
      return article["title"]!.toLowerCase().contains(q) ||
          article["description"]!.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/ArticlesBackground.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // المحتوى
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Column(
                children: [
                  // شريط البحث
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: "ابحث عن مقال...",
                        hintStyle: const TextStyle(fontSize: 14),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.75),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // قائمة المقالات
                  Expanded(
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final art = filtered[i];
                            return FadeInUp(
                              duration: Duration(milliseconds: 400 + (i * 150)),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(2, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      art["image"]!,
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    art["title"]!,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Text(
                                    art["description"]!,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ArticleDetailScreen(article: art),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
