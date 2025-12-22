import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AppointmentAPI {
  // 1) طلب موعد مع أخصائي نفسي
  static Future<Map<String, dynamic>> requestPsychologistAppointment({
    required String sessionToken,
    required String childId,
    required String providerId,
    required String appointmentPlanId,
    String? note,
  }) async {
    try {
      print(" Requesting appointment: child=$childId, provider=$providerId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/requestPsychologistAppointment"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "child_id": childId,
          "provider_id": providerId,
          "appointment_plan_id": appointmentPlanId,
          if (note != null) "note": note,
        }),
      );
      
      print(" Appointment Status: ${response.statusCode}");
      print(" Appointment Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل طلب الموعد: ${response.statusCode}"};
        }
      }
    } catch (e) {
      print(" Appointment Exception: $e");
      return {"error": "تعذر طلب الموعد: $e"};
    }
  }
  
  // 2) جلب مواعيد طفل معين
  static Future<List<Map<String, dynamic>>> getChildAppointments({
    required String sessionToken,
    required String childId,
  }) async {
    try {
      print(" Fetching appointments for child: $childId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getChildAppointments"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"child_id": childId}),
      );
      
      print(" Appointments Status: ${response.statusCode}");
      print(" Appointments Response: ${response.body}");
      
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
      print(" Get Appointments Exception: $e");
      return [];
    }
  }
  
  // 3) جلب تفاصيل موعد محدد
  static Future<Map<String, dynamic>> getAppointmentDetails({
    required String sessionToken,
    required String appointmentId,
  }) async {
    try {
      print(" Fetching appointment details: $appointmentId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getAppointmentDetails"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"appointment_id": appointmentId}),
      );
      
      print(" Appointment Details Status: ${response.statusCode}");
      print(" Appointment Details Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل جلب تفاصيل الموعد"};
        }
      }
    } catch (e) {
      print(" Get Appointment Details Exception: $e");
      return {"error": "تعذر جلب تفاصيل الموعد: $e"};
    }
  }
  
  // 4) جلب المواعيد المعلّقة للمزوّد
  static Future<List<Map<String, dynamic>>> getPendingAppointmentsForProvider({
    required String sessionToken,
  }) async {
    try {
      print(" Fetching pending appointments for provider");
      
      final uri = Uri.parse("${ApiConfig.baseUrl}/getPendingAppointmentsForProvider");
      print("Calling URI: $uri");

      final response = await http.post(
        uri,
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({}),
      );
      
      print(" Pending Appointments Status: ${response.statusCode}");
      print(" Pending Appointments Response: ${response.body}");
      
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
      print(" Get Pending Appointments Exception: $e");
      return [];
    }
  }
  
  // 5) التحقق من إمكانية الوصول لتقييم طفل
  static Future<Map<String, dynamic>> canAccessChildEvaluation({
    required String sessionToken,
    required String childId,
  }) async {
    try {
      print(" Checking access for child evaluation: $childId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/canAccessChildEvaluation"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"child_id": childId}),
      );
      
      print(" Access Check Status: ${response.statusCode}");
      print(" Access Check Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"canAccess": false, "error": "فشل التحقق من الصلاحية"};
        }
      }
    } catch (e) {
      print(" Access Check Exception: $e");
      return {"canAccess": false, "error": "تعذر التحقق من الصلاحية: $e"};
    }
  }
  
  // 6) اتخاذ قرار بخصوص موعد (موافقة/رفض)
  static Future<Map<String, dynamic>> handleAppointmentDecision({
    required String sessionToken,
    required String appointmentId,
    required String decision, // "approve" أو "reject"
  }) async {
    try {
      print(" Handling appointment decision: $appointmentId, decision=$decision");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/handleAppointmentDecision"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "appointment_id": appointmentId,
          "decision": decision,
        }),
      );
      
      print(" Decision Status: ${response.statusCode}");
      print(" Decision Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل معالجة القرار"};
        }
      }
    } catch (e) {
      print(" Handle Decision Exception: $e");
      return {"error": "تعذر معالجة القرار: $e"};
    }
  }

  // 7) جلب حجوزات الطبيب/الأخصائي
  static Future<List<Map<String, dynamic>>> getProviderAppointments({
    required String sessionToken,
    String? providerId,
  }) async {
    try {
      print(" Fetching appointments for provider: ${providerId ?? 'current'}");
      
      final body = providerId != null ? {"provider_id": providerId} : {};

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getPendingAppointmentsForProvider"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode(body),
      );
      
      print(" Provider Appointments Status: ${response.statusCode}");
      print(" Provider Appointments Response: ${response.body}");
      
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
      print(" Get Provider Appointments Exception: $e");
      return [];
    }
  }

  // 8) إلغاء موعد (للآباء)
  static Future<Map<String, dynamic>> cancelAppointment({
    required String sessionToken,
    required String appointmentId,
  }) async {
    try {
      print(" Cancelling appointment: $appointmentId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/cancelAppointment"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"appointment_id": appointmentId}),
      );
      
      print(" Cancel Appointment Status: ${response.statusCode}");
      print(" Cancel Appointment Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إلغاء الموعد"};
        }
      }
    } catch (e) {
      print(" Cancel Appointment Exception: $e");
      return {"error": "تعذر إلغاء الموعد: $e"};
    }
  }
}






