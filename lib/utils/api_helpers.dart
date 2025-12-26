import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class APIHelpers {
  
  static Future<String> getSessionToken() async {
    try {
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null && token.isNotEmpty) {
        print(' Got session token from SharedPreferences: ${token.substring(0, 10)}...');
        return token;
      }
    
      
      final user = await ParseUser.currentUser() as ParseUser?;
      if (user != null && user.sessionToken != null) {
        print('Got session token from ParseUser: ${user.sessionToken!.substring(0, 10)}...');
        return user.sessionToken!;
      }
      
      print('No session token found');
      throw Exception('No user logged in');
    } catch (e) {
      print('Error getting session token: $e');
      rethrow;
    }
  }

  
  static Future<String?> getUserId() async {
    try {
      
      final prefs = await SharedPreferences.getInstance();
      
      final userId = prefs.getString('userId') ?? prefs.getString('objectId');
      
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }
      
      
      final user = await ParseUser.currentUser() as ParseUser?;
      if (user != null && user.objectId != null) {
        return user.objectId;
      }
      
      return null;
    } catch (e) {
      print(' Error getting user ID: $e');
      return null;
    }
  }


  static Future<bool> isUserLoggedIn() async {
    try {
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final hasSession = prefs.getBool('hasSession') ?? false;
      
      if (token != null && token.isNotEmpty && hasSession) {
        return true;
      }
      
      
      final user = await ParseUser.currentUser() as ParseUser?;
      return user != null;
    } catch (e) {
      print(' Error checking login status: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = await ParseUser.currentUser() as ParseUser?;
      if (user == null) return null;

      return {
        'objectId': user.objectId,
        'username': user.username,
        'email': user.emailAddress,
        'sessionToken': user.sessionToken,
      };
    } catch (e) {
      print(' Error getting current user: $e');
      return null;
    }
  }

  
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  static void showSuccessDialog(BuildContext context, String message,
      {VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نجح'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDismiss?.call();
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message ?? 'جاري التحميل...'),
          ],
        ),
      ),
    );
  }


  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  
  static bool handleAPIResponse(
    BuildContext context,
    Map<String, dynamic> response, {
    String? successMessage,
    VoidCallback? onSuccess,
  }) {
    if (response.containsKey('error')) {
      showErrorDialog(context, response['error']);
      return false;
    } else {
      if (successMessage != null) {
        showSuccessDialog(context, successMessage, onDismiss: onSuccess);
      } else {
        onSuccess?.call();
      }
      return true;
    }
  }

  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} ل.س';
  }

  
  static DateTime? parseDateTime(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print(' Error parsing date: $e');
      return null;
    }
  }


  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }


  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10,}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }


  static Color getAppointmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending_payment':
        return Colors.orange;
      case 'pending_provider_approval':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  
  static String getAppointmentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending_payment':
        return 'بانتظار الدفع';
      case 'pending_provider_approval':
        return 'بانتظار موافقة المزود';
      case 'approved':
        return 'تمت الموافقة';
      case 'rejected':
        return 'مرفوض';
      case 'completed':
        return 'مكتمل';
      default:
        return status;
    }
  }

  
  static Color getChargeRequestStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  
  static String getChargeRequestStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'بانتظار المراجعة';
      case 'approved':
        return 'تمت الموافقة';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }
  static Color getTransactionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return Colors.red;
      case 'refund':
        return Colors.green;
      case 'reversal':
        return Colors.orange;
      case 'charge':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  
  static String getTransactionTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return 'دفع';
      case 'refund':
        return 'استرداد';
      case 'reversal':
        return 'عكس';
      case 'charge':
        return 'شحن';
      default:
        return type;
    }
  }


  static bool hasSufficientBalance(double balance, double amount) {
    return balance >= amount;
  }

  static double calculateRemainingBalance(double balance, double amount) {
    return balance - amount;
  }
}
