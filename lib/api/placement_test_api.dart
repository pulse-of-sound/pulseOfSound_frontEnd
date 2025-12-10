import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class PlacementTestAPI {
  // 1) جلب جميع أسئلة اختبار المستوى - Child only
  static Future<List<Map<String, dynamic>>> getPlacementTestQuestions({
    required String sessionToken,
  }) async {
    try {
      print(" Fetching placement test questions");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getPlacementTestQuestions"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Questions Status: ${response.statusCode}");
      print(" Questions Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
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
  
  // 2) جلب سؤال حسب الفهرس - Child only
  static Future<Map<String, dynamic>> getPlacementTestQuestionByIndex({
    required String sessionToken,
    required int index,
  }) async {
    try {
      print(" Fetching question at index: $index");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getPlacementTestQuestionByIndex"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"index": index}),
      );
      
      print(" Question Status: ${response.statusCode}");
      print(" Question Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل جلب السؤال"};
        }
      }
    } catch (e) {
      print(" Get Question Exception: $e");
      return {"error": "تعذر جلب السؤال: $e"};
    }
  }
  
  // 3) إرسال إجابات اختبار المستوى
  static Future<Map<String, dynamic>> submitPlacementTestAnswers({
    required String sessionToken,
    required List<Map<String, String>> answers, // [{questionId, selectedOption}]
  }) async {
    try {
      print(" Submitting placement test answers: ${answers.length} answers");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/submitPlacementTestAnswers"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"answers": answers}),
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
}



