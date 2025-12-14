import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserStageStatusAPI {
  // 1) تعليم مرحلة كمكتملة
  static Future<Map<String, dynamic>> markStageCompleted({
    required String sessionToken,
    required String levelGameId,
    double? score,
  }) async {
    try {
      print(" Marking stage as completed: $levelGameId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/markStageCompleted"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "level_game_id": levelGameId,
          if (score != null) "score": score,
        }),
      );
      
      print(" Mark Completed Status: ${response.statusCode}");
      print(" Mark Completed Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل تعليم المرحلة كمكتملة"};
        }
      }
    } catch (e) {
      print(" Mark Completed Exception: $e");
      return {"error": "تعذر تعليم المرحلة كمكتملة: $e"};
    }
  }
  
  // 2) جلب حالة مراحل المستخدم
  static Future<List<Map<String, dynamic>>> getUserStageStatus({
    required String sessionToken,
  }) async {
    try {
      print(" Fetching user stage status");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getUserStageStatus"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({}),
      );
      
      print(" Stage Status Status: ${response.statusCode}");
      print(" Stage Status Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("stages")) {
          final stages = data["stages"];
          if (stages is List) {
            return List<Map<String, dynamic>>.from(stages);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get User Stage Status Exception: $e");
      return [];
    }
  }
  
  // 3) إعادة تعيين تقدم المرحلة
  static Future<Map<String, dynamic>> resetStageProgress({
    required String sessionToken,
    required String levelGameId,
  }) async {
    try {
      print(" Resetting stage progress: $levelGameId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/resetStageProgress"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"level_game_id": levelGameId}),
      );
      
      print(" Reset Progress Status: ${response.statusCode}");
      print(" Reset Progress Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إعادة تعيين التقدم"};
        }
      }
    } catch (e) {
      print(" Reset Progress Exception: $e");
      return {"error": "تعذر إعادة تعيين التقدم: $e"};
    }
  }
  
  // 4) تعديل حالة مرحلة بواسطة الأدمن - Admin only
  static Future<Map<String, dynamic>> adminOverrideStageStatus({
    required String sessionToken,
    required String levelGameId,
    required String newStatus,
    required String targetUserId,
    double? score,
  }) async {
    try {
      print(" Admin overriding stage status: $levelGameId for user: $targetUserId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/adminOverrideStageStatus"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "level_game_id": levelGameId,
          "new_status": newStatus,
          "target_user_id": targetUserId,
          if (score != null) "score": score,
        }),
      );
      
      print(" Override Status: ${response.statusCode}");
      print(" Override Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل تعديل حالة المرحلة"};
        }
      }
    } catch (e) {
      print(" Override Status Exception: $e");
      return {"error": "تعذر تعديل حالة المرحلة: $e"};
    }
  }
}






