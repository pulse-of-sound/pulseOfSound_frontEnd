// lib/Doctor/utils/doctor_chat_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorChatService {
  static const _communityKey = "global_community_chat";
  static const _bannedUsersKey = "banned_users_list";

  ///  تحميل رسائل المجتمع
  static Future<List<Map<String, dynamic>>> loadCommunity() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_communityKey);
    if (jsonStr == null) return [];
    final List decoded = jsonDecode(jsonStr);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// إضافة رسالة للمجتمع
  static Future<void> addCommunity(String sender, String text,
      {String? imagePath}) async {
    final prefs = await SharedPreferences.getInstance();
    final banned = await getBannedUsers();
    if (banned.contains(sender)) return;
    final jsonStr = prefs.getString(_communityKey);
    final List list = jsonStr == null ? [] : jsonDecode(jsonStr);
    list.add({
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "sender": sender,
      "text": text,
      "image": imagePath,
      "time": DateTime.now().toIso8601String(),
    });
    await prefs.setString(_communityKey, jsonEncode(list));
  }

  /// حذف رسالة معينة حسب id
  static Future<void> deleteMessage(String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_communityKey);
    if (jsonStr == null) return;
    final List list = jsonDecode(jsonStr);
    list.removeWhere((msg) => msg["id"] == messageId);
    await prefs.setString(_communityKey, jsonEncode(list));
  }

  /// إضافة مستخدم إلى قائمة الحظر
  static Future<void> banUser(String senderName) async {
    final prefs = await SharedPreferences.getInstance();
    final banned = await getBannedUsers();
    banned.add(senderName);
    await prefs.setString(_bannedUsersKey, jsonEncode(banned.toList()));
  }

  /// إزالة مستخدم من الحظر
  static Future<void> unbanUser(String senderName) async {
    final prefs = await SharedPreferences.getInstance();
    final banned = await getBannedUsers();
    banned.remove(senderName);
    await prefs.setString(_bannedUsersKey, jsonEncode(banned.toList()));
  }

 
  static Future<Set<String>> getBannedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_bannedUsersKey);
    if (jsonStr == null) return {};
    final List decoded = jsonDecode(jsonStr);
    return decoded.map((e) => e.toString()).toSet();
  }
 

  static Future<void> createPrivateChat({
    required String chatId,
    required String doctorId,
    required String parentId,
    required String parentName,
    required int durationMinutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final startTime = DateTime.now();
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    final chatInfo = {
      "chatId": chatId,
      "doctorId": doctorId,
      "parentId": parentId,
      "parentName": parentName,
      "durationMinutes": durationMinutes, 
      "isClosed": false,
      "startTime": startTime.toIso8601String(),
      "endTime": endTime.toIso8601String(),
      "messages": [],
    };

    await prefs.setString("chat_$chatId", jsonEncode(chatInfo));

    // ⏱ مؤقت الإغلاق التلقائي بعد انتهاء الوقت المحدد
    Timer(Duration(minutes: durationMinutes), () async {
      final data = prefs.getString("chat_$chatId");
      if (data != null) {
        final decoded = jsonDecode(data);
        decoded["isClosed"] = true;
        await prefs.setString("chat_$chatId", jsonEncode(decoded));
      }
    });
  }

  ///  تحميل محادثة خاصة حسب chatId
  static Future<Map<String, dynamic>?> loadChatInfo(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString("chat_$chatId");
    if (jsonStr == null) return null;
    return Map<String, dynamic>.from(jsonDecode(jsonStr));
  }

  ///  جلب الرسائل فقط
  static Future<List<Map<String, dynamic>>> loadChatMessages(
      String chatId) async {
    final info = await loadChatInfo(chatId);
    if (info == null) return [];
    final List decoded = info["messages"] ?? [];
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  ///  إرسال رسالة للمحادثة الخاصة (فقط إن لم تنتهي)
  static Future<void> addPrivateMessage(
    String chatId,
    String sender,
    String text, {
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("chat_$chatId");
    if (data == null) return;

    final decoded = jsonDecode(data);
    if (decoded["isClosed"] == true) {
  
      return;
    }

    final List messages =
        decoded["messages"] == null ? [] : decoded["messages"] as List;

    messages.add({
      "sender": sender,
      "text": text,
      "image": imagePath,
      "time": DateTime.now().toIso8601String(),
    });

    decoded["messages"] = messages;
    await prefs.setString("chat_$chatId", jsonEncode(decoded));
  }

  ///  فحص إذا المحادثة مغلقة
  static Future<bool> isChatClosed(String chatId) async {
    final info = await loadChatInfo(chatId);
    if (info == null) return true;
    return info["isClosed"] == true;
  }

  ///  إغلاق المحادثة يدويًا (من الطبيب أو النظام)
  static Future<void> closeChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("chat_$chatId");
    if (data == null) return;
    final decoded = jsonDecode(data);
    decoded["isClosed"] = true;
    await prefs.setString("chat_$chatId", jsonEncode(decoded));
  }

  ///  حذف محادثة
  static Future<void> clearChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("chat_$chatId");
  }
}
