import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class TrainingQuestionAPI {
  // 1) جلب السؤال التدريبي التالي
  static Future<Map<String, dynamic>> getNextTrainingQuestion({
    required String sessionToken,
    required String questionId,
    required String selectedOption,
  }) async {
    try {
      print(" Getting next training question after: $questionId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getNextTrainingQuestion"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "question_id": questionId,
          "selected_option": selectedOption,
        }),
      );
      
      print(" Next Question Status: ${response.statusCode}");
      print(" Next Question Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل جلب السؤال التالي"};
        }
      }
    } catch (e) {
      print(" Get Next Question Exception: $e");
      return {"error": "تعذر جلب السؤال التالي: $e"};
    }
  }
}

