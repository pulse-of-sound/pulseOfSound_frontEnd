import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class InvoiceAPI {
  // 1) إنشاء فاتورة لموعد
  static Future<Map<String, dynamic>> createInvoiceForAppointment({
    required String sessionToken,
    required String appointmentId,
  }) async {
    try {
      print(" Creating invoice for appointment: $appointmentId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/createInvoiceForAppointment"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"appointment_id": appointmentId}),
      );
      
      print(" Invoice Status: ${response.statusCode}");
      print(" Invoice Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إنشاء الفاتورة"};
        }
      }
    } catch (e) {
      print(" Create Invoice Exception: $e");
      return {"error": "تعذر إنشاء الفاتورة: $e"};
    }
  }
  
  // 2) تأكيد دفع فاتورة
  static Future<Map<String, dynamic>> confirmInvoicePayment({
    required String sessionToken,
    required String invoiceId,
  }) async {
    try {
      print(" Confirming invoice payment: $invoiceId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/confirmInvoicePayment"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"invoice_id": invoiceId}),
      );
      
      print(" Confirm Payment Status: ${response.statusCode}");
      print(" Confirm Payment Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل تأكيد الدفع"};
        }
      }
    } catch (e) {
      print(" Confirm Payment Exception: $e");
      return {"error": "تعذر تأكيد الدفع: $e"};
    }
  }
}






