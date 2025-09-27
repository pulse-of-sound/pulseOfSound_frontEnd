import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static SharedPreferences? _prefs;

  // 🔹 لازم تنادي هالدالة أول ما يفتح التطبيق (مثلاً بالـ main)
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== حفظ البيانات ==========
  static Future setHasSession(bool value) async {
    await _prefs?.setBool("hasSession", value);
  }

  static Future setUserType(String value) async {
    await _prefs?.setString("userType", value);
  }

  static Future setToken(String value) async {
    await _prefs?.setString("token", value);
  }

  static Future setUserId(String value) async {
    await _prefs?.setString("userId", value);
  }

  // ========== قراءة البيانات ==========
  static bool getHasSession() {
    return _prefs?.getBool("hasSession") ?? false;
  }

  static String? getUserType() {
    return _prefs?.getString("userType");
  }

  static String? getToken() {
    return _prefs?.getString("token");
  }

  static String? getUserId() {
    return _prefs?.getString("userId");
  }

  // ========== مسح البيانات ==========
  static Future clear() async {
    await _prefs?.clear();
  }
}
