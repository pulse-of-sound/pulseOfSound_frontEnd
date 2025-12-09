import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ChildProfileAPI {
  // 1) جلب أو إنشاء ملف الطفل الخاص بي
  static Future<Map<String, dynamic>> getMyChildProfile({
    required String sessionToken,
  }) async {
    try {
      print(" Fetching my child profile");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getMyChildProfile"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Child Profile Status: ${response.statusCode}");
      print(" Child Profile Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل جلب ملف الطفل"};
        }
      }
    } catch (e) {
      print(" Get Child Profile Exception: $e");
      return {"error": "تعذر جلب ملف الطفل: $e"};
    }
  }
  
  // 2) إنشاء أو تحديث ملف طفل
  static Future<Map<String, dynamic>> createOrUpdateChildProfile({
    required String childId,
    String? name,
    String? fatherName,
    String? birthdate,
    String? gender,
    String? medicalInfo,
  }) async {
    try {
      print(" Creating/updating child profile: $childId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/createOrUpdateChildProfile"),
        headers: ApiConfig.getHeadersWithMasterKey(),
        body: jsonEncode({
          "childId": childId,
          if (name != null) "name": name,
          if (fatherName != null) "fatherName": fatherName,
          if (birthdate != null) "birthdate": birthdate,
          if (gender != null) "gender": gender,
          if (medicalInfo != null) "medical_info": medicalInfo,
        }),
      );
      
      print(" Child Profile Status: ${response.statusCode}");
      print(" Child Profile Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إنشاء/تحديث ملف الطفل"};
        }
      }
    } catch (e) {
      print(" Create/Update Child Profile Exception: $e");
      return {"error": "تعذر إنشاء/تحديث ملف الطفل: $e"};
    }
  }
}

class ChildLevelAPI {
  // 1) تعيين مستوى للطفل إذا نجح
  static Future<Map<String, dynamic>> assignChildLevelIfPassed({
    required String sessionToken,
    required String childId,
  }) async {
    try {
      print(" Assigning level to child: $childId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/assignChildLevelIfPassed"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"child_id": childId}),
      );
      
      print(" Assign Level Status: ${response.statusCode}");
      print(" Assign Level Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل تعيين المستوى"};
        }
      }
    } catch (e) {
      print(" Assign Level Exception: $e");
      return {"error": "تعذر تعيين المستوى: $e"};
    }
  }
  
  // 2) جلب المرحلة الحالية للطفل
  static Future<Map<String, dynamic>> getCurrentStageForChild({
    required String sessionToken,
    required String childId,
  }) async {
    try {
      print(" Fetching current stage for child: $childId");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getCurrentStageForChild").replace(
          queryParameters: {"child_id": childId},
        ),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Current Stage Status: ${response.statusCode}");
      print(" Current Stage Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل جلب المرحلة الحالية"};
        }
      }
    } catch (e) {
      print(" Get Current Stage Exception: $e");
      return {"error": "تعذر جلب المرحلة الحالية: $e"};
    }
  }
  
  // 3) التقدم أو إعادة المرحلة
  static Future<Map<String, dynamic>> advanceOrRepeatStage({
    required String sessionToken,
    required String childId,
    required String stageId,
    required bool passed,
  }) async {
    try {
      print(" Advancing/repeating stage: $stageId for child: $childId, passed=$passed");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/advanceOrRepeatStage"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "child_id": childId,
          "stage_id": stageId,
          "passed": passed,
        }),
      );
      
      print(" Advance Stage Status: ${response.statusCode}");
      print(" Advance Stage Response: ${response.body}");
      
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
      print(" Advance Stage Exception: $e");
      return {"error": "تعذر التقدم/إعادة المرحلة: $e"};
    }
  }
  
  // 4) التحقق من إكمال المستوى
  static Future<Map<String, dynamic>> getLevelCompletionStatus({
    required String sessionToken,
    required String childId,
  }) async {
    try {
      print(" Checking level completion for child: $childId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getLevelCompletionStatus"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"child_id": childId}),
      );
      
      print(" Level Completion Status: ${response.statusCode}");
      print(" Level Completion Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل التحقق من إكمال المستوى"};
        }
      }
    } catch (e) {
      print(" Level Completion Exception: $e");
      return {"error": "تعذر التحقق من إكمال المستوى: $e"};
    }
  }
  
  // 5) التحقق من إكمال مرحلة معينة
  static Future<Map<String, dynamic>> getStageCompletionStatus({
    required String sessionToken,
    required String childId,
    required String stageId,
  }) async {
    try {
      print(" Checking stage completion: $stageId for child: $childId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getStageCompletionStatus"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "child_id": childId,
          "stage_id": stageId,
        }),
      );
      
      print(" Stage Completion Status: ${response.statusCode}");
      print(" Stage Completion Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل التحقق من إكمال المرحلة"};
        }
      }
    } catch (e) {
      print(" Stage Completion Exception: $e");
      return {"error": "تعذر التحقق من إكمال المرحلة: $e"};
    }
  }
}

