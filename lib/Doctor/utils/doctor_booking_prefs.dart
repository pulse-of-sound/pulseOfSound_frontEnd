import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorBookingPrefs {
  static const _key = "doctor_bookings";

  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final List decoded = jsonDecode(jsonStr);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> save(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list));
  }

  static Future<void> add(Map<String, dynamic> booking) async {
    final list = await load();
    list.insert(0, booking);
    await save(list);
  }

  static Future<void> update(Map<String, dynamic> updated) async {
    final list = await load();
    final i = list.indexWhere((x) => x["id"] == updated["id"]);
    if (i != -1) list[i] = updated;
    await save(list);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
