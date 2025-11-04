import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorArticlesPrefs {
  static const _doctorKey = "doctor_articles";
  static const _adminKey = "admin_pending_articles";
  static const _approvedKey = "approved_articles";

  /// تحميل مقالات الطبيب فقط
  static Future<List<Map<String, dynamic>>> loadDoctorArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_doctorKey);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// تحميل المقالات الموافق عليها (يستخدمها الأهالي)
  static Future<List<Map<String, dynamic>>> loadApprovedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_approvedKey);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// الطبيب يرسل مقال → يروح للأدمن للمراجعة
  static Future<void> submitArticle(Map<String, dynamic> article) async {
    final prefs = await SharedPreferences.getInstance();

    final doctorList = await loadDoctorArticles();
    doctorList.add(article);
    await prefs.setString(_doctorKey, jsonEncode(doctorList));

    final pending = await loadPendingArticles();
    pending.add(article);
    await prefs.setString(_adminKey, jsonEncode(pending));
  }

  /// تحميل المقالات المعلقة عند الأدمن
  static Future<List<Map<String, dynamic>>> loadPendingArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_adminKey);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// الموافقة على المقال من قبل الأدمن
  static Future<void> approveArticle(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await loadPendingArticles();
    if (index >= pending.length) return;
    final article = pending[index];
    article["status"] = "approved";

    // حفظ المقال بقائمة الموافق عليها
    final approved = await loadApprovedArticles();
    approved.add(article);
    await prefs.setString(_approvedKey, jsonEncode(approved));

    // حذف المقال من المعلّقة
    pending.removeAt(index);
    await prefs.setString(_adminKey, jsonEncode(pending));
  }

  /// رفض مقال من الأدمن
  static Future<void> rejectArticle(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await loadPendingArticles();
    if (index >= pending.length) return;
    pending[index]["status"] = "rejected";
    await prefs.setString(_adminKey, jsonEncode(pending));
  }
}
