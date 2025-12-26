import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_config.dart';

class ChargeRequestAPI {
  //  إنشاء طلب شحن رصيد
  static Future<Map<String, dynamic>> createChargeRequest({
    required String sessionToken,
    required double amount,
    String? note,
    File? receiptImage,
  }) async {
    try {
      print(" Creating charge request: $amount");

      if (receiptImage != null) {
        // رفع مع ملف
        final request = http.MultipartRequest(
          'POST',
          Uri.parse("${ApiConfig.baseUrl}/createChargeRequest"),
        );

        request.headers.addAll(ApiConfig.getUploadHeaders(sessionToken));
        request.fields['amount'] = amount.toString();
        if (note != null) request.fields['note'] = note;

        request.files.add(
          await http.MultipartFile.fromPath(
            'receipt_image',
            receiptImage.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print(" Charge Request Status: ${response.statusCode}");
        print(" Charge Request Response: ${response.body}");

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          try {
            return jsonDecode(response.body);
          } catch (e) {
            return {"error": "فشل إنشاء طلب الشحن"};
          }
        }
      } else {
        // رفع بدون ملف
        final response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/createChargeRequest"),
          headers: ApiConfig.getHeadersWithToken(sessionToken),
          body: jsonEncode({
            "amount": amount,
            if (note != null) "note": note,
          }),
        );

        print(" Charge Request Status: ${response.statusCode}");
        print(" Charge Request Response: ${response.body}");

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          try {
            return jsonDecode(response.body);
          } catch (e) {
            return {"error": "فشل إنشاء طلب الشحن"};
          }
        }
      }
    } catch (e) {
      print(" Create Charge Request Exception: $e");
      return {"error": "تعذر إنشاء طلب الشحن: $e"};
    }
  }

  //  الموافقة على طلب شحن - Admin only
  static Future<Map<String, dynamic>> approveChargeRequest({
    required String sessionToken,
    required String chargeRequestId,
  }) async {
    try {
      print(" Approving charge request: $chargeRequestId");

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/approveChargeRequest"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"charge_request_id": chargeRequestId}),
      );

      print(" Approve Status: ${response.statusCode}");
      print(" Approve Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل الموافقة على طلب الشحن"};
        }
      }
    } catch (e) {
      print(" Approve Charge Request Exception: $e");
      return {"error": "تعذر الموافقة على طلب الشحن: $e"};
    }
  }

  //  رفض طلب شحن - Admin only
  static Future<Map<String, dynamic>> rejectChargeRequest({
    required String sessionToken,
    required String chargeRequestId,
    required String rejectionNote,
  }) async {
    try {
      print(" Rejecting charge request: $chargeRequestId");

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/rejectChargeRequest"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "charge_request_id": chargeRequestId,
          "rejection_note": rejectionNote,
        }),
      );

      print(" Reject Status: ${response.statusCode}");
      print(" Reject Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل رفض طلب الشحن"};
        }
      }
    } catch (e) {
      print(" Reject Charge Request Exception: $e");
      return {"error": "تعذر رفض طلب الشحن: $e"};
    }
  }

  //  جلب جميع طلبات الشحن - Admin only
  static Future<List<Map<String, dynamic>>> getChargeRequests({
    required String sessionToken,
    String? status,
  }) async {
    try {
      print(" Fetching charge requests");

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getChargeRequests"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          if (status != null) "status": status,
        }),
      );

      print(" Charge Requests Status: ${response.statusCode}");
      print(" Charge Requests Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("requests")) {
          final requests = data["requests"];
          if (requests is List) {
            return List<Map<String, dynamic>>.from(requests);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get Charge Requests Exception: $e");
      return [];
    }
  }
}





