import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

// Helper function to get user_id from SharedPreferences
Future<String> _getUserIdFromToken(String sessionToken) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId') ?? '';
}

class ProgressAPI {
  /// Get child progress statistics and game results
  static Future<Map<String, dynamic>> getChildProgress({
    required String sessionToken,
    String? childId,
  }) async {
    try {
      final headers = ApiConfig.getHeadersWithToken(sessionToken);
      print(' Request URL: ${ApiConfig.baseUrl}/getChildProgress');
      print(' Request Headers: $headers');
      print(' Request Body: ${jsonEncode({if (childId != null) 'child_id': childId})}');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/getChildProgress'),
        headers: headers,
        body: jsonEncode({
          'user_id': await _getUserIdFromToken(sessionToken),  // Add user_id
          if (childId != null) 'child_id': childId,
        }),
      );

      print(' Progress API Response: ${response.statusCode}');
      print(' Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(' Progress Data: $data');
        return data;
      } else {
        print(' Progress API Error: ${response.body}');
        throw Exception('Failed to fetch child progress: ${response.statusCode}');
      }
    } catch (e) {
      print(' Progress API Exception: $e');
      rethrow;
    }
  }
}
