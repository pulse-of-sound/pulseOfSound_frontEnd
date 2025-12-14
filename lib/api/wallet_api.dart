import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class WalletAPI {
  // 1) جلب رصيد المحفظة
  static Future<Map<String, dynamic>> getWalletBalance({
    required String sessionToken,
  }) async {
    try {
      print(" Fetching wallet balance");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getWalletBalance"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Wallet Balance Status: ${response.statusCode}");
      print(" Wallet Balance Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل جلب رصيد المحفظة"};
        }
      }
    } catch (e) {
      print(" Get Wallet Balance Exception: $e");
      return {"error": "تعذر جلب رصيد المحفظة: $e"};
    }
  }
}

class WalletTransactionAPI {
  // 1) إنشاء معاملة محفظة
  static Future<Map<String, dynamic>> createWalletTransaction({
    required String sessionToken,
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String type,
    String? appointmentId,
  }) async {
    try {
      print(" Creating wallet transaction: $amount from $fromWalletId to $toWalletId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/createWalletTransaction"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "from_wallet_id": fromWalletId,
          "to_wallet_id": toWalletId,
          "amount": amount,
          "type": type,
          if (appointmentId != null) "appointment_id": appointmentId,
        }),
      );
      
      print(" Transaction Status: ${response.statusCode}");
      print(" Transaction Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إنشاء المعاملة"};
        }
      }
    } catch (e) {
      print(" Create Transaction Exception: $e");
      return {"error": "تعذر إنشاء المعاملة: $e"};
    }
  }
  
  // 2) جلب معاملات محفظة معينة
  static Future<List<Map<String, dynamic>>> getWalletTransactions({
    required String sessionToken,
    required String walletId,
    String? type,
    String? appointmentId,
  }) async {
    try {
      print(" Fetching transactions for wallet: $walletId");
      
      final queryParams = <String, String>{"wallet_id": walletId};
      if (type != null) queryParams["type"] = type;
      if (appointmentId != null) queryParams["appointment_id"] = appointmentId;
      
      final uri = Uri.parse("${ApiConfig.baseUrl}/getWalletTransactions").replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Transactions Status: ${response.statusCode}");
      print(" Transactions Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("transactions")) {
          final transactions = data["transactions"];
          if (transactions is List) {
            return List<Map<String, dynamic>>.from(transactions);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get Transactions Exception: $e");
      return [];
    }
  }
  
  // 3) جلب معاملات مرتبطة بموعد
  static Future<List<Map<String, dynamic>>> getTransactionsByAppointment({
    required String sessionToken,
    required String appointmentId,
  }) async {
    try {
      print(" Fetching transactions for appointment: $appointmentId");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getTransactionsByAppointment").replace(
          queryParameters: {"appointment_id": appointmentId},
        ),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Appointment Transactions Status: ${response.statusCode}");
      print(" Appointment Transactions Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("transactions")) {
          final transactions = data["transactions"];
          if (transactions is List) {
            return List<Map<String, dynamic>>.from(transactions);
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print(" Get Appointment Transactions Exception: $e");
      return [];
    }
  }
  
  // 4) عكس معاملة (Reversal) - Admin only
  static Future<Map<String, dynamic>> reverseTransaction({
    required String sessionToken,
    required String transactionId,
    String? reason,
  }) async {
    try {
      print(" Reversing transaction: $transactionId");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/reverseTransaction"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "transaction_id": transactionId,
          if (reason != null) "reason": reason,
        }),
      );
      
      print(" Reverse Transaction Status: ${response.statusCode}");
      print(" Reverse Transaction Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل عكس المعاملة"};
        }
      }
    } catch (e) {
      print(" Reverse Transaction Exception: $e");
      return {"error": "تعذر عكس المعاملة: $e"};
    }
  }
  
  // 5) جلب تفاصيل معاملة محددة
  static Future<Map<String, dynamic>> getTransactionById({
    required String sessionToken,
    required String transactionId,
  }) async {
    try {
      print(" Fetching transaction details: $transactionId");
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/getTransactionById").replace(
          queryParameters: {"transaction_id": transactionId},
        ),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );
      
      print(" Transaction Details Status: ${response.statusCode}");
      print(" Transaction Details Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل جلب تفاصيل المعاملة"};
        }
      }
    } catch (e) {
      print(" Get Transaction Details Exception: $e");
      return {"error": "تعذر جلب تفاصيل المعاملة: $e"};
    }
  }
}






