// // lib/Doctor/utils/doctor_prefs.dart
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class DoctorPrefs {
//   static const _profileKey = "doctor_profile"; // بيانات الدكتور الحالي
//   static const _doctorsListKey = "doctors_list"; // (اختياري) قائمة أطباء مسجلين

//   // حفظ بروفايل الدكتور الحالي (map يحتوي id, name, avatarPath)
//   static Future<void> saveProfile(Map<String, dynamic> profile) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_profileKey, jsonEncode(profile));
//   }

//   static Future<Map<String, dynamic>?> loadProfile() async {
//     final prefs = await SharedPreferences.getInstance();
//     final s = prefs.getString(_profileKey);
//     if (s == null) return null;
//     try {
//       return Map<String, dynamic>.from(jsonDecode(s));
//     } catch (_) {
//       return null;
//     }
//   }

//   static Future<void> clearProfile() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_profileKey);
//   }

//   // Optional: إدارة قائمة أطباء محلياً
//   static Future<List<Map<String, dynamic>>> loadDoctorsList() async {
//     final prefs = await SharedPreferences.getInstance();
//     final s = prefs.getString(_doctorsListKey);
//     if (s == null) return [];
//     final List decoded = jsonDecode(s);
//     return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
//   }

//   static Future<void> saveDoctorsList(List<Map<String, dynamic>> list) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_doctorsListKey, jsonEncode(list));
//   }
// }
