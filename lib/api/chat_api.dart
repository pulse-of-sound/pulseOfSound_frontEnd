import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ChatAPI {
  static Future<Map<String, dynamic>> getMyChatGroups({required String sessionToken}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/getMyChatGroups'),
      headers: ApiConfig.getHeadersWithToken(sessionToken),
      body: jsonEncode({}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getChatMessages({
    required String sessionToken,
    required String chatGroupId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/getChatMessages'),
      headers: ApiConfig.getHeadersWithToken(sessionToken),
      body: jsonEncode({'chat_group_id': chatGroupId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendChatMessage({
    required String sessionToken,
    required String chatGroupId,
    required String message,
    String? childId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/sendChatMessage'),
      headers: ApiConfig.getHeadersWithToken(sessionToken),
      body: jsonEncode({
        'chat_group_id': chatGroupId,
        'message': message,
        if (childId != null) 'child_id': childId,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getChatHistory({
    required String sessionToken,
    required String chatGroupId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/getChatHistory'),
      headers: ApiConfig.getHeadersWithToken(sessionToken),
      body: jsonEncode({'chat_group_id': chatGroupId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createCommunityChatGroup({
    required String sessionToken,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/createCommunityChatGroup'),
      headers: ApiConfig.getHeadersWithToken(sessionToken),
      body: jsonEncode({'name': name}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteChatMessage({
    required String sessionToken,
    required String chatMessageId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/deleteChatMessage'),
      headers: ApiConfig.getHeadersWithToken(sessionToken),
      body: jsonEncode({'chat_message_id': chatMessageId}),
    );
    return jsonDecode(response.body);
  }
}
