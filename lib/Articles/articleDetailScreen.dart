import 'package:flutter/material.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/articles.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 22, top: 30),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.pinkAccent, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  article["title"] ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  article["image"] ?? "images/articles1.jpg",
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    article["description"] ?? "",
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
