import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class TrainingQuestionAPI {
  static Map<String, dynamic> _fixImageUrls(Map<String, dynamic> response) {
    final fixed = Map<String, dynamic>.from(response);
    
    // معالجة question_image_url
    if (fixed['question_image_url'] is String) {
      String url = fixed['question_image_url'] as String;
      if (url.contains('[object Object]')) {
        fixed['question_image_url'] = '';
        print("⚠️ WARNING: Invalid question_image_url detected");
      } else {
        fixed['question_image_url'] = ApiConfig.fixUrlHost(url);
      }
    } else if (fixed['question_image_url'] == null) {
      fixed['question_image_url'] = '';
    }
    
    // معالجة options
    if (fixed['options'] is Map) {
      final options = Map<String, dynamic>.from(fixed['options']);
      options.forEach((key, value) {
        if (value is String) {
          String url = value;
          if (url.contains('[object Object]')) {
            options[key] = '';
            print("⚠️ WARNING: Invalid option URL detected for option $key");
          } else {
            options[key] = ApiConfig.fixUrlHost(url);
          }
        } else {
          options[key] = '';
        }
      });
      fixed['options'] = options;
    }
    
    return fixed;
  }

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
        final data = jsonDecode(response.body);
        if (data is Map) {
          final fixed = _fixImageUrls(data as Map<String, dynamic>);
          print(" FIXED URLs for Android: $fixed");
          return fixed;
        }
        return data;
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





