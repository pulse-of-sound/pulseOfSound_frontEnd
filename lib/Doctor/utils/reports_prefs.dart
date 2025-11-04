import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorReportsPrefs {
  static const _key = "doctor_reports";

  static Future<void> addReport(
      String parentId, String parentName, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final List list = jsonDecode(prefs.getString(_key) ?? "[]");
    list.add({
      "parentId": parentId,
      "parentName": parentName,
      "content": content,
      "time": DateTime.now().toIso8601String(),
    });
    await prefs.setString(_key, jsonEncode(list));
  }

  static Future<List<Map<String, dynamic>>> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final List decoded = jsonDecode(jsonStr);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> clearReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
