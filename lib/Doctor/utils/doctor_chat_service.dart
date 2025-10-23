import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorChatService {
  static const _privateKey = "doctor_private_chats";
  static const _communityKey = "doctor_community_chat";

  // ✅ تحميل محادثات خاصة
  static Future<List<Map<String, String>>> loadPrivate() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_privateKey);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, String>.from(e)).toList();
  }

  // ✅ تحميل محادثات المجتمع
  static Future<List<Map<String, String>>> loadCommunity() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_communityKey);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, String>.from(e)).toList();
  }

  // ✅ إضافة رسالة خاصة
  static Future<void> addPrivate(String sender, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_privateKey);
    final List list = data == null ? [] : jsonDecode(data);
    list.add({"sender": sender, "text": text});
    await prefs.setString(_privateKey, jsonEncode(list));
  }

  // ✅ إضافة رسالة للمجتمع
  static Future<void> addCommunity(String sender, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_communityKey);
    final List list = data == null ? [] : jsonDecode(data);
    list.add({"sender": sender, "text": text});
    await prefs.setString(_communityKey, jsonEncode(list));
  }

  // ✅ دعم مستقبلي لو حبيت تربط حسب chatId
  static Future<List<Map<String, String>>> loadMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("chat_$chatId");
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, String>.from(e)).toList();
  }

  static Future<void> addMessage(
      String chatId, String sender, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final messages = await loadMessages(chatId);
    messages.insert(0, {"sender": sender, "text": text});
    await prefs.setString("chat_$chatId", jsonEncode(messages));
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_privateKey);
    await prefs.remove(_communityKey);
  }

  static Future<void> clearChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("chat_$chatId");
  }
}
