import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AppointmentPlanAPI {
  // 1) إنشاء خطة موعد جديدة
  static Future<Map<String, dynamic>> createAppointmentPlan({
    required String sessionToken,
    required String title,
    required int durationMinutes,
    required double price,
    String? description,
  }) async {
    try {
      print(" Creating appointment plan: $title");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/createAppointmentPlan"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "title": title,
          "duration_minutes": durationMinutes,
          "price": price,
          if (description != null) "description": description,
        }),
      );
      
      print(" Create Plan Status: ${response.statusCode}");
      print(" Create Plan Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إنشاء خطة الموعد"};
        }
      }
    } catch (e) {
      print(" Create Plan Exception: $e");
      return {"error": "تعذر إنشاء خطة الموعد: $e"};
    }
  }
  
  // 2) جلب جميع خطط المواعيد المتاحة
  static Future<List<Map<String, dynamic>>> getAvailableAppointmentPlans({
    required String sessionToken,
  }) async {
    try {
      print(" Fetching available appointment plans");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getAvailableAppointmentPlans"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({}),
      );
      
      print(" Plans Status: ${response.statusCode}");
      print(" Plans Response: ${response.body}");
      
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
      print(" Get Plans Exception: $e");
      return [];
    }
  }
}






