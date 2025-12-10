import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthAPI {
  static const String serverUrl = "http://localhost:1337/api/functions";
  static const String appId = "cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7";

  static const Map<String, String> headers = {
    "Content-Type": "application/json",
    "X-Parse-Application-Id": appId,
  };

// 1) إرسال OTP
// endpoint = sendOtp

  static Future<Map<String, dynamic>> generateOTP(String mobile) async {
    try {
      final url = Uri.parse("$serverUrl/generateOTP");

      print(" Requesting OTP from: $url");
      print(" Phone: $mobile");

      final response = await http.post(
        url,
        headers: {
          "X-Parse-Application-Id": appId,
          "X-Parse-Client-Key": "null",
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"mobileNumber": mobile}),
      );

      print(" Status Code: ${response.statusCode}");
      print(" Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "خطأ: ${response.statusCode} - ${response.body}"};
        }
      }
    } catch (e) {
      print(" Exception: $e");
      return {"error": "خطأ في الاتصال بالسيرفر: $e"};
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(
      String mobile, String otp) async {
    try {
      print(" Verifying OTP: $otp for $mobile");

      final response = await http.post(
        Uri.parse("$serverUrl/verifyOTP"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Client-Key": "null",
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "mobileNumber": mobile,
          "OTP": otp,
          "platform": "flutter",
          "locale": "ar",
        }),
      );

      print(" Verify Status Code: ${response.statusCode}");
      print(" Verify Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "خطأ: ${response.statusCode} - ${response.body}"};
        }
      }
    } catch (e) {
      print(" Verify Exception: $e");
      return {"error": "تعذر الاتصال بالخادم: $e"};
    }
  }


// 2) تسجيل دخول المستخدم (الطفل) عبر رقم الهاتف + OTP
// endpoint = loginWithMobile

  static Future<Map<String, dynamic>> loginWithMobile(
      String mobile, String otp) async {
    try {
      print(" Logging in with Mobile: $mobile");

      // محاولة الـ login عبر Backend أولاً
      final response = await http.post(
        Uri.parse("$serverUrl/loginWithMobile"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Client-Key": "null",
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "mobileNumber": mobile,
          "OTP": otp,
          "platform": "flutter",
          "locale": "ar",
        }),
      );

      print(" Login Status Code: ${response.statusCode}");
      print(" Login Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // إذا فشل Backend، إنشاء user من Frontend
        print(" Backend login failed, creating user from Flutter...");
        return await _createOrLoginUserDirectly(mobile, otp);
      }
    } catch (e) {
      print(" Login Exception: $e");
      // محاولة الإنشاء المباشر كخطة احتياطية
      return await _createOrLoginUserDirectly(mobile, otp);
    }
  }

  static Future<Map<String, dynamic>> _createOrLoginUserDirectly(
      String mobile, String otp) async {
    try {
      final username = "mobile_$mobile";
      final password = "otp_${DateTime.now().millisecondsSinceEpoch}";

      // محاولة البحث عن user موجود
      final queryUrl = Uri.parse("$serverUrl/../classes/User");
      final queryResponse = await http.get(
        queryUrl,
        headers: {
          "X-Parse-Application-Id": appId,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
      );

      // إنشاء user جديد
      final createUrl = Uri.parse("$serverUrl/../users");
      final createResponse = await http.post(
        createUrl,
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "username": username,
          "password": password,
          "mobileNumber": mobile,
        }),
      );

      print(" Create User Status: ${createResponse.statusCode}");
      print(" Create User Response: ${createResponse.body}");

      if (createResponse.statusCode == 201 ||
          createResponse.statusCode == 200) {
        final userData = jsonDecode(createResponse.body);
        
        // محاولة الدخول للحصول على sessionToken
        final loginUrl = Uri.parse("$serverUrl/../login");
        final loginResp = await http.post(
          loginUrl,
          headers: {
            "Content-Type": "application/json",
            "X-Parse-Application-Id": appId,
            "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
          },
          body: jsonEncode({
            "username": username,
            "password": password,
          }),
        );

        if (loginResp.statusCode == 200) {
          final loginData = jsonDecode(loginResp.body);
          return {
            "sessionToken": loginData["sessionToken"] ?? userData["sessionToken"] ?? "",
            "mobileNumber": mobile,
            "username": username,
            "userId": userData["objectId"] ?? "",
          };
        }

        return {
          "sessionToken": userData["sessionToken"] ?? userData["id"] ?? "",
          "mobileNumber": mobile,
          "username": username,
          "userId": userData["objectId"] ?? "",
        };
      } else {
        return {"error": "فشل إنشاء المستخدم"};
      }
    } catch (e) {
      print(" Direct Create Exception: $e");
      return {"error": "فشل إنشاء المستخدم: $e"};
    }
  }


  static Future<Map<String, dynamic>> loginAfterOTP(String mobile) async {
    try {
      print(" Logging in after OTP for: $mobile");

      final response = await http.post(
        Uri.parse("$serverUrl/loginAfterOTP"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Client-Key": "null",
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "mobileNumber": mobile,
          "platform": "flutter",
          "locale": "ar",
        }),
      );

      print(" Login After OTP Status Code: ${response.statusCode}");
      print(" Login After OTP Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {"error": "دور هذا المستخدم غير مدعوم للتسجيل عبر OTP. يرجى استخدام اسم المستخدم وكلمة المرور."};
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "خطأ: ${response.statusCode} - ${response.body}"};
        }
      }
    } catch (e) {
      print(" Login After OTP Exception: $e");
      return {"error": "تعذر الاتصال بالخادم: $e"};
    }
  }
  
}
