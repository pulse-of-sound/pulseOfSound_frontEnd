import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorArticlesPrefs {
  static const _key = "doctor_articles";

  static Future<List<Map<String, dynamic>>> loadArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> addArticle(Map<String, dynamic> article) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadArticles();
    list.add(article);
    await prefs.setString(_key, jsonEncode(list));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
