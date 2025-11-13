import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChildProgressPrefs {
  static const _key = "child_daily_evaluations";

  //  إضافة تقييم جديد (نستدعيه عند انتهاء المرحلة)
  static Future<void> addDailyEvaluation(
      Map<String, dynamic> evaluation) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    final List list = data == null ? [] : jsonDecode(data);
    list.add(evaluation);
    await prefs.setString(_key, jsonEncode(list));
  }

  //  تحميل كل التقييمات
  static Future<List<Map<String, dynamic>>> loadEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  //  مسح كل التقييمات (اختياري)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
