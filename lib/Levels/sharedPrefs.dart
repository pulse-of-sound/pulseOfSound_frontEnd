import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  //  حفظ قيمة من نوع int
  static Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  //  جلب قيمة من نوع int
  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  //  حفظ نص (String)
  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  //  جلب نص (String)
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  //  حفظ قيمة من نوع Boolean
  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  //  جلب قيمة Boolean
  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  //  حذف مفتاح واحد
  static Future<void> removeKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  //  مسح كل البيانات (لتسجيل خروج أو إعادة تعيين)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // من أجل تقدم المرحلة الحالية
  static Future<void> setCurrentStage(int level, int group, int stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level_${level}_group_${group}_stage', stage);
  }

  static Future<int> getCurrentStage(int level, int group) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('level_${level}_group_${group}_stage') ?? 0;
  }

  //  لتخزين آخر تاريخ لعب
  static Future<void> setLastPlayDate(int level, int group, String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastPlayDate_Level${level}_Group$group', date);
  }

  static Future<String?> getLastPlayDate(int level, int group) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastPlayDate_Level${level}_Group$group');
  }

  //  لتخزين المجموعة المفتوحة بالمستوى
  static Future<void> setUnlockedGroup(int level, int group) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unlockedGroup_Level$level', group);
  }

  static Future<int> getUnlockedGroup(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unlockedGroup_Level$level') ?? 1;
  }

  //  لتخزين آخر مستوى منجز
  static Future<void> setCompletedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completedLevel', level);
  }

  static Future<int> getCompletedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('completedLevel') ?? 0;
  }
}
