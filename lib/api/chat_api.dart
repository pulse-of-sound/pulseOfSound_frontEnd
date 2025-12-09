import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ChatGroupAPI {
  // 1) إنشاء مجموعة محادثة لموعد
  static Future<Map<String, dynamic>> createChatGroupForAppointment({
    required String sessionToken,
    required String appointmentId,
  }) async {
    try {
      print(" Creating chat group for appointment: $appointmentId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/createChatGroupForAppointment"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"appointment_id": appointmentId}),
      );
      
      print(" Chat Group Status: ${response.statusCode}");
      print(" Chat Group Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إنشاء مجموعة المحادثة"};
        }
      }
    } catch (e) {
      print(" Create Chat Group Exception: $e");
      return {"error": "تعذر إنشاء مجموعة المحادثة: $e"};
    }
  }
  
  // 2) جلب مجموعات المحادثة الخاصة بي
  static Future<List<Map<String, dynamic>>> getMyChatGroups({
    required String sessionToken,
  }) async {
    try {
      print(" Fetching my chat groups");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getMyChatGroups"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Chat Groups Status: ${response.statusCode}");
      print(" Chat Groups Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("chat_groups")) {
          final groups = data["chat_groups"];
          if (groups is List) {
            return List<Map<String, dynamic>>.from(groups);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get Chat Groups Exception: $e");
      return [];
    }
  }
  
  // 3) جلب المشاركين في مجموعة محادثة
  static Future<List<Map<String, dynamic>>> getChatParticipants({
    required String sessionToken,
    required String chatGroupId,
  }) async {
    try {
      print(" Fetching chat participants: $chatGroupId");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getChatParticipants").replace(
          queryParameters: {"chat_group_id": chatGroupId},
        ),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Participants Status: ${response.statusCode}");
      print(" Participants Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("participants")) {
          final participants = data["participants"];
          if (participants is List) {
            return List<Map<String, dynamic>>.from(participants);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get Participants Exception: $e");
      return [];
    }
  }
  
  // 4) أرشفة مجموعة محادثة - Admin only
  static Future<Map<String, dynamic>> archiveChatGroup({
    required String sessionToken,
    required String chatGroupId,
  }) async {
    try {
      print(" Archiving chat group: $chatGroupId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/archiveChatGroup"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"chat_group_id": chatGroupId}),
      );
      
      print(" Archive Status: ${response.statusCode}");
      print(" Archive Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل أرشفة مجموعة المحادثة"};
        }
      }
    } catch (e) {
      print(" Archive Chat Group Exception: $e");
      return {"error": "تعذر أرشفة مجموعة المحادثة: $e"};
    }
  }
}

class ChatGroupParticipantAPI {
  // 1) إزالة مشارك من مجموعة - Admin only
  static Future<Map<String, dynamic>> removeParticipantFromGroup({
    required String sessionToken,
    required String chatGroupId,
    required String participantId,
  }) async {
    try {
      print(" Removing participant: $participantId from group: $chatGroupId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/removeParticipantFromGroup"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "chat_group_id": chatGroupId,
          "participant_id": participantId,
        }),
      );
      
      print(" Remove Participant Status: ${response.statusCode}");
      print(" Remove Participant Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إزالة المشارك"};
        }
      }
    } catch (e) {
      print(" Remove Participant Exception: $e");
      return {"error": "تعذر إزالة المشارك: $e"};
    }
  }
  
  // 2) كتم مشارك - Admin only
  static Future<Map<String, dynamic>> muteParticipant({
    required String sessionToken,
    required String chatGroupId,
    required String participantId,
    required int durationInDays,
  }) async {
    try {
      print(" Muting participant: $participantId for $durationInDays days");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/muteParticipant"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "chat_group_id": chatGroupId,
          "participant_id": participantId,
          "duration_in_days": durationInDays,
        }),
      );
      
      print(" Mute Status: ${response.statusCode}");
      print(" Mute Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل كتم المشارك"};
        }
      }
    } catch (e) {
      print(" Mute Participant Exception: $e");
      return {"error": "تعذر كتم المشارك: $e"};
    }
  }
  
  // 3) إلغاء الكتم عن مشارك - Admin only
  static Future<Map<String, dynamic>> unmuteParticipant({
    required String sessionToken,
    required String chatGroupId,
    required String participantId,
  }) async {
    try {
      print(" Unmuting participant: $participantId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/unmuteParticipant"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "chat_group_id": chatGroupId,
          "participant_id": participantId,
        }),
      );
      
      print(" Unmute Status: ${response.statusCode}");
      print(" Unmute Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إلغاء الكتم"};
        }
      }
    } catch (e) {
      print(" Unmute Participant Exception: $e");
      return {"error": "تعذر إلغاء الكتم: $e"};
    }
  }
  
  // 4) جلب المشاركين في مجموعة
  static Future<List<Map<String, dynamic>>> getParticipantsInGroup({
    required String sessionToken,
    required String chatGroupId,
  }) async {
    try {
      print(" Fetching participants in group: $chatGroupId");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getParticipantsInGroup").replace(
          queryParameters: {"chat_group_id": chatGroupId},
        ),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Participants Status: ${response.statusCode}");
      print(" Participants Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("participants")) {
          final participants = data["participants"];
          if (participants is List) {
            return List<Map<String, dynamic>>.from(participants);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get Participants Exception: $e");
      return [];
    }
  }
}

class ChatMessageAPI {
  // 1) إرسال رسالة
  static Future<Map<String, dynamic>> sendChatMessage({
    required String sessionToken,
    required String chatGroupId,
    required String message,
    String? childId,
  }) async {
    try {
      print(" Sending message to group: $chatGroupId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/sendChatMessage"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "chat_group_id": chatGroupId,
          "message": message,
          if (childId != null) "child_id": childId,
        }),
      );
      
      print(" Send Message Status: ${response.statusCode}");
      print(" Send Message Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إرسال الرسالة"};
        }
      }
    } catch (e) {
      print(" Send Message Exception: $e");
      return {"error": "تعذر إرسال الرسالة: $e"};
    }
  }
  
  // 2) جلب رسائل مجموعة
  static Future<List<Map<String, dynamic>>> getChatMessages({
    required String sessionToken,
    required String chatGroupId,
  }) async {
    try {
      print(" Fetching messages for group: $chatGroupId");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getChatMessages").replace(
          queryParameters: {"chat_group_id": chatGroupId},
        ),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Messages Status: ${response.statusCode}");
      print(" Messages Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("messages")) {
          final messages = data["messages"];
          if (messages is List) {
            return List<Map<String, dynamic>>.from(messages);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get Messages Exception: $e");
      return [];
    }
  }
  
  // 3) تعليم رسالة كمقروءة
  static Future<Map<String, dynamic>> markMessageAsRead({
    required String sessionToken,
    required String chatMessageId,
  }) async {
    try {
      print(" Marking message as read: $chatMessageId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/markMessageAsRead"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"chat_message_id": chatMessageId}),
      );
      
      print(" Mark Read Status: ${response.statusCode}");
      print(" Mark Read Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل تعليم الرسالة كمقروءة"};
        }
      }
    } catch (e) {
      print(" Mark Read Exception: $e");
      return {"error": "تعذر تعليم الرسالة كمقروءة: $e"};
    }
  }
  
  // 4) جلب مجموعات المحادثة الخاصة بالمستخدم
  static Future<List<Map<String, dynamic>>> getUserChatGroups({
    required String sessionToken,
  }) async {
    try {
      print(" Fetching user chat groups");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getUserChatGroups"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" User Chat Groups Status: ${response.statusCode}");
      print(" User Chat Groups Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("chat_groups")) {
          final groups = data["chat_groups"];
          if (groups is List) {
            return List<Map<String, dynamic>>.from(groups);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get User Chat Groups Exception: $e");
      return [];
    }
  }
  
  // 5) جلب سجل محادثة لمجموعة
  static Future<List<Map<String, dynamic>>> getChatHistory({
    required String sessionToken,
    required String chatGroupId,
  }) async {
    try {
      print(" Fetching chat history for group: $chatGroupId");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getChatHistory").replace(
          queryParameters: {"chat_group_id": chatGroupId},
        ),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Chat History Status: ${response.statusCode}");
      print(" Chat History Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("messages")) {
          final messages = data["messages"];
          if (messages is List) {
            return List<Map<String, dynamic>>.from(messages);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get Chat History Exception: $e");
      return [];
    }
  }
}

