import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LevelAPI {
  // 1) إضافة مستوى جديد
  static Future<Map<String, dynamic>> addLevelByAdmin({
    required String name,
    String? description,
    required int order,
  }) async {
    try {
      print(" Adding level: $name, order=$order");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/addLevelByAdmin"),
        headers: ApiConfig.getHeadersWithMasterKey(),
        body: jsonEncode({
          "name": name,
          if (description != null) "description": description,
          "order": order,
        }),
      );
      
      print(" Add Level Status: ${response.statusCode}");
      print(" Add Level Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إضافة المستوى"};
        }
      }
    } catch (e) {
      print(" Add Level Exception: $e");
      return {"error": "تعذر إضافة المستوى: $e"};
    }
  }
  
  // 2) جلب جميع المستويات
  static Future<List<Map<String, dynamic>>> getAllLevels() async {
    try {
      print(" Fetching all levels");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getAllLevels"),
        headers: ApiConfig.getHeadersWithMasterKey(),
        body: jsonEncode({}),
      );
      
      print(" Levels Status: ${response.statusCode}");
      print(" Levels Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("levels")) {
          final levels = data["levels"];
          if (levels is List) {
            return List<Map<String, dynamic>>.from(levels);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get Levels Exception: $e");
      return [];
    }
  }
  
  // 3) جلب مستوى حسب ID
  static Future<Map<String, dynamic>> getLevelById({
    required String levelId,
  }) async {
    try {
      print(" Fetching level: $levelId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getLevelById"),
        headers: ApiConfig.getBaseHeaders(),
        body: jsonEncode({"level_id": levelId}),
      );
      
      print(" Level Status: ${response.statusCode}");
      print(" Level Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل جلب المستوى"};
        }
      }
    } catch (e) {
      print(" Get Level Exception: $e");
      return {"error": "تعذر جلب المستوى: $e"};
    }
  }
  
  // 4) حذف مستوى - Admin only
  static Future<Map<String, dynamic>> deleteLevel({
    required String sessionToken,
    required String levelId,
  }) async {
    try {
      print("🗑️ Deleting level: $levelId");
      print("🔑 SessionToken: $sessionToken");
      print("🔑 Token length: ${sessionToken.length}");
      
      final headers = ApiConfig.getHeadersWithToken(sessionToken);
      print("📤 Headers: $headers");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/deleteLevel"),
        headers: headers,
        body: jsonEncode({"level_id": levelId}),
      );
      
      print("📥 Delete Level Status: ${response.statusCode}");
      print("📥 Delete Level Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل حذف المستوى"};
        }
      }
    } catch (e) {
      print("❌ Delete Level Exception: $e");
      return {"error": "تعذر حذف المستوى: $e"};
    }
  }
}

class LevelGameAPI {
  // 1) إضافة مرحلة جديدة لمستوى
  static Future<Map<String, dynamic>> addLevelGameByAdmin({
    required String sessionToken,
    required String levelId,
    required String name,
    required int order,
  }) async {
    try {
      print("➕ Adding level game: $name to level: $levelId, order=$order");
      print("🔑 SessionToken: $sessionToken");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/addLevelGameByAdmin"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "levelId": levelId,
          "name": name,
          "order": order,
        }),
      );
      
      print("📥 Add Level Game Status: ${response.statusCode}");
      print("📥 Add Level Game Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إضافة المرحلة"};
        }
      }
    } catch (e) {
      print("❌ Add Level Game Exception: $e");
      return {"error": "تعذر إضافة المرحلة: $e"};
    }
  }
  
  // 2) جلب جميع مراحل مستوى معين
  static Future<List<Map<String, dynamic>>> getLevelGamesForLevel({
    required String levelId,
  }) async {
    try {
      print(" Fetching level games for level: $levelId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getLevelGamesForLevel"),
        headers: ApiConfig.getHeadersWithMasterKey(),
        body: jsonEncode({"level_id": levelId}),
      );
      
      print(" Level Games Status: ${response.statusCode}");
      print(" Level Games Response: ${response.body}");
      
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
      print(" Get Level Games Exception: $e");
      return [];
    }
  }
  
  // 3) جلب المرحلة التالية
  static Future<Map<String, dynamic>> getNextStageOrder({
    required String levelId,
    required int currentOrder,
  }) async {
    try {
      print(" Getting next stage for level: $levelId, current order=$currentOrder");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getNextStageOrder"),
        headers: ApiConfig.getBaseHeaders(),
        body: jsonEncode({
          "level_id": levelId,
          "current_order": currentOrder,
        }),
      );
      
      print(" Next Stage Status: ${response.statusCode}");
      print(" Next Stage Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل جلب المرحلة التالية"};
        }
      }
    } catch (e) {
      print(" Get Next Stage Exception: $e");
      return {"error": "تعذر جلب المرحلة التالية: $e"};
    }
  }
  
  // 4) التقدم أو إعادة المرحلة
  static Future<Map<String, dynamic>> advanceOrRepeatStage({
    required String sessionToken,
    required String childId,
    required String stageId,
    bool passed = true,
  }) async {
    try {
      print(" Advancing/repeating stage: $stageId for child: $childId, passed=$passed");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/advanceOrRepeatStage"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "child_id": childId,
          "stage_id": stageId,
          if (passed) "passed": passed,
        }),
      );
      
      print(" Advance/Repeat Status: ${response.statusCode}");
      print(" Advance/Repeat Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل التقدم/إعادة المرحلة"};
        }
      }
    } catch (e) {
      print(" Advance/Repeat Exception: $e");
      return {"error": "تعذر التقدم/إعادة المرحلة: $e"};
    }
  }
}






