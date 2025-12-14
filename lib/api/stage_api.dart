import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class StageQuestionAPI {
  // 1) إضافة أسئلة إلى مرحلة - Admin only
  static Future<Map<String, dynamic>> addQuestionsToStage({
    required String sessionToken,
    required String levelGameId,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      print(" Adding ${questions.length} questions to stage: $levelGameId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/addQuestionsToStage"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "level_game_id": levelGameId,
          "questions": questions,
        }),
      );
      
      print(" Add Questions Status: ${response.statusCode}");
      print(" Add Questions Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إضافة الأسئلة"};
        }
      }
    } catch (e) {
      print(" Add Questions Exception: $e");
      return {"error": "تعذر إضافة الأسئلة: $e"};
    }
  }
  
  // 2) حذف أسئلة مرحلة حسب IDs - Admin only
  static Future<Map<String, dynamic>> deleteStageQuestionsByIds({
    required String sessionToken,
    required List<String> questionIds,
  }) async {
    try {
      print(" Deleting ${questionIds.length} questions");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/deleteStageQuestionsByIds"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"question_ids": questionIds}),
      );
      
      print(" Delete Questions Status: ${response.statusCode}");
      print(" Delete Questions Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل حذف الأسئلة"};
        }
      }
    } catch (e) {
      print(" Delete Questions Exception: $e");
      return {"error": "تعذر حذف الأسئلة: $e"};
    }
  }
  
  // 3) جلب أسئلة مرحلة معينة
  static Future<List<Map<String, dynamic>>> getStageQuestions({
    required String sessionToken,
    required String levelGameId,
  }) async {
    try {
      print(" Fetching questions for stage: $levelGameId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getStageQuestions"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"level_game_id": levelGameId}),
      );
      
      print(" Questions Status: ${response.statusCode}");
      print(" Questions Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("questions")) {
          final questions = data["questions"];
          if (questions is List) {
            return List<Map<String, dynamic>>.from(questions);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get Questions Exception: $e");
      return [];
    }
  }
}

class StageResultAPI {
  // 1) إرسال إجابات مرحلة
  static Future<Map<String, dynamic>> submitStageAnswers({
    required String sessionToken,
    required String levelGameId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      print(" Submitting stage answers: $levelGameId, ${answers.length} answers");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/submitStageAnswers"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "level_game_id": levelGameId,
          "answers": answers,
        }),
      );
      
      print(" Submit Answers Status: ${response.statusCode}");
      print(" Submit Answers Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إرسال الإجابات"};
        }
      }
    } catch (e) {
      print(" Submit Answers Exception: $e");
      return {"error": "تعذر إرسال الإجابات: $e"};
    }
  }
  
  // 2) جلب نتيجة مرحلة
  static Future<Map<String, dynamic>> getStageResult({
    required String sessionToken,
    required String levelGameId,
  }) async {
    try {
      print(" Fetching stage result: $levelGameId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getStageResult"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"level_game_id": levelGameId}),
      );
      
      print(" Stage Result Status: ${response.statusCode}");
      print(" Stage Result Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل جلب نتيجة المرحلة"};
        }
      }
    } catch (e) {
      print(" Get Stage Result Exception: $e");
      return {"error": "تعذر جلب نتيجة المرحلة: $e"};
    }
  }
  
  // 3) جلب سجل محاولات المرحلة
  static Future<List<Map<String, dynamic>>> getStageHistory({
    required String sessionToken,
    required String levelGameId,
  }) async {
    try {
      print(" Fetching stage history: $levelGameId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getStageHistory"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"level_game_id": levelGameId}),
      );
      
      print(" Stage History Status: ${response.statusCode}");
      print(" Stage History Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("history")) {
          final history = data["history"];
          if (history is List) {
            return List<Map<String, dynamic>>.from(history);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get Stage History Exception: $e");
      return [];
    }
  }
}






