import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static SharedPreferences? _prefs;

  ///  تهيئة SharedPreferences (مناداة بـ main)
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ------------------- الجلسة -------------------
  static Future setSession(bool hasSession) async {
    await _prefs?.setBool("hasSession", hasSession);
  }

  static bool getSession() {
    return _prefs?.getBool("hasSession") ?? false;
  }

  // ------------------- نوع المستخدم -------------------
  static Future setUserType(String type) async {
    await _prefs?.setString("userType", type);
  }

  static String getUserType() {
    return _prefs?.getString("userType") ?? "guest";
  }

  // ------------------- بيانات المصادقة -------------------
  static Future setToken(String token) async {
    print(" DEBUG SharedPrefsHelper.setToken: storing token = '$token'");
    print(" DEBUG SharedPrefsHelper.setToken: token length = ${token.length}");
    await _prefs?.setString("token", token);
    final verify = _prefs?.getString("token");
    print(" DEBUG SharedPrefsHelper.setToken: verified stored token = '$verify'");
  }

  static String? getToken() {
    final token = _prefs?.getString("token");
    print(" DEBUG SharedPrefsHelper.getToken: retrieving token = '$token'");
    print(" DEBUG SharedPrefsHelper.getToken: token length = ${token?.length}");
    return token;
  }

  static Future setUserId(String userId) async {
    await _prefs?.setString("userId", userId);
  }

  static String? getUserId() {
    return _prefs?.getString("userId");
  }

  // ------------------- بيانات المستخدم -------------------
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

  // ------------------- بيانات المحفظة -------------------
  static Future<void> setWalletImage(String path) async {
    await _prefs?.setString("walletImage", path);
  }

  static Future<String?> getWalletImage() async {
    return _prefs?.getString("walletImage");
  }

  // ------------------- مسح الكل -------------------
  static Future clear() async {
    await _prefs?.clear();
  }

  // ------------------- التحقق من الأدوار -------------------
  /// التحقق من أن المستخدم هو SuperAdmin
  static bool isSuperAdmin() {
    final role = getUserType();
    final normalizedRole = role.toUpperCase();
    return normalizedRole == "SUPER_ADMIN" || normalizedRole == "SUPERADMIN" || role == "SuperAdmin";
  }

  /// التحقق من أن المستخدم هو Admin
  static bool isAdmin() {
    final role = getUserType();
    final normalizedRole = role.toUpperCase();
    return normalizedRole == "ADMIN" || normalizedRole == "SUPER_ADMIN" || normalizedRole == "SUPERADMIN" || role == "SuperAdmin";
  }

  /// التحقق من أن المستخدم لديه صلاحيات SuperAdmin أو Admin
  static bool hasAdminPermissions() {
    return isAdmin();
  }

  /// التحقق من أن المستخدم لديه صلاحيات SuperAdmin فقط
  static bool hasSuperAdminPermissions() {
    return isSuperAdmin();
  }
}
