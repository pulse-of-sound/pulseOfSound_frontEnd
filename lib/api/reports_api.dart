import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ReportsAPI {
  static Future<Map<String, dynamic>> submitReport({
    required String sessionToken,
    required String appointmentId,
    required String content,
    String? summary,
    String? childId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/submitReport'),
      headers: ApiConfig.getHeadersWithToken(sessionToken),
      body: jsonEncode({
        'appointment_id': appointmentId,
        'content': content,
        if (summary != null) 'summary': summary,
        if (childId != null) 'child_id': childId,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getReportsForChild({
    required String sessionToken,
    required String childId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/getReportsForChild'),
      headers: ApiConfig.getHeadersWithToken(sessionToken),
      body: jsonEncode({'child_id': childId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getReportsForParent({
    required String sessionToken,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/getReportsForParent'),
      headers: ApiConfig.getHeadersWithToken(sessionToken),
      body: jsonEncode({}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getReportsForDoctor({
    required String sessionToken,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/getReportsForDoctor'),
      headers: ApiConfig.getHeadersWithToken(sessionToken),
      body: jsonEncode({}),
    );
    return jsonDecode(response.body);
  }
}
