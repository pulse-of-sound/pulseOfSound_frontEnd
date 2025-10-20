import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static SharedPreferences? _prefs;

  /// ✅ تهيئة SharedPreferences
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// ------------------- الجلسة -------------------
  static Future setSession(bool hasSession) async {
    await _prefs?.setBool("hasSession", hasSession);
  }

  static bool getSession() {
    return _prefs?.getBool("hasSession") ?? false;
  }

  /// ------------------- نوع المستخدم -------------------
  static Future setUserType(String type) async {
    await _prefs?.setString("userType", type);
  }

  static String getUserType() {
    return _prefs?.getString("userType") ?? "guest";
  }

  /// ------------------- بيانات المستخدم -------------------
  static Future setPhone(String phone) async {
    await _prefs?.setString("phone", phone);
  }

  static String? getPhone() {
    return _prefs?.getString("phone");
  }

  static Future setName(String name) async {
    await _prefs?.setString("name", name);
  }

  static String? getName() {
    return _prefs?.getString("name");
  }

  static Future setFatherName(String fatherName) async {
    await _prefs?.setString("fatherName", fatherName);
  }

  static String? getFatherName() {
    return _prefs?.getString("fatherName");
  }

  static Future setAge(int age) async {
    await _prefs?.setInt("age", age);
  }

  static int? getAge() {
    return _prefs?.getInt("age");
  }

  static Future setBirthDate(String date) async {
    await _prefs?.setString("birthDate", date);
  }

  static String? getBirthDate() {
    return _prefs?.getString("birthDate");
  }

  static Future setGender(String gender) async {
    await _prefs?.setString("gender", gender);
  }

  static String? getGender() {
    return _prefs?.getString("gender");
  }

  static Future setHealthStatus(String status) async {
    await _prefs?.setString("healthStatus", status);
  }

  static String? getHealthStatus() {
    return _prefs?.getString("healthStatus");
  }

  static Future setProfileImage(String path) async {
    await _prefs?.setString("profileImage", path);
  }

  static String? getProfileImage() {
    return _prefs?.getString("profileImage");
  }

  /// ------------------- مسح البيانات -------------------
  static Future clear() async {
    await _prefs?.clear();
  }

  //المحفظة
  static Future<void> setWalletImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("walletImage", path);
  }

  static Future<String?> getWalletImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("walletImage");
  }
}
