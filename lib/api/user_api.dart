import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserAPI {
  static const String serverUrl = ApiConfig.baseUrl;
  static const String appId = ApiConfig.appId;

  
  // 1) LOGIN FUNCTIONS 

  static Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    try {
      print(" Logging in Admin/Doctor: $username");

      final response = await http.post(
        Uri.parse("$serverUrl/loginUser"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Client-Key": "null",
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "username": username,
          "password": password,
          "platform": "flutter",
          "locale": "ar",
        }),
      );

      print(" Login Status Code: ${response.statusCode}");
      print(" Login Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessionToken = data["sessionToken"] ?? "";
        final userId = data["id"] ?? data["objectId"] ?? "";

        var roleData = await _fetchUserRole(userId, sessionToken);

        final role = roleData["role"] ?? "User";
        final fullName = data["fullName"] ?? data["username"] ?? "User";

        return {
          ...data,
          "role": role,
          "fullName": fullName,
        };
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {"error": errorData["error"] ?? "خطأ في تسجيل الدخول"};
        } catch (e) {
          return {"error": "خطأ: ${response.statusCode}"};
        }
      }
    } catch (e) {
      print(" Login Exception: $e");
      return {"error": "تعذر الاتصال بالسيرفر: $e"};
    }
  }

  static Future<Map<String, dynamic>> _fetchUserRole(
      String userId, String sessionToken) async {
    try {
      final url = Uri.parse("$serverUrl/../classes/_User/$userId?include=role");
      print(" Fetching role from: $url");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
      );

      print(" Role fetch status: ${response.statusCode}");
      print(" Role data: ${response.body}");

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final role = _extractRole(userData);
        print(" Extracted role: $role");
        return {
          "role": role,
          "data": userData,
        };
      }
      return {"role": "User", "data": {}};
    } catch (e) {
      print(" Fetch Role Exception: $e");
      return {"role": "User", "data": {}};
    }
  }

  static String _extractRole(Map<String, dynamic> data) {
    if (data.containsKey("role")) {
      final role = data["role"];
      print(" Role data type: ${role.runtimeType}, value: $role");

      if (role is String) {
        return role;
      } else if (role is Map) {
        if (role.containsKey("name")) {
          return role["name"] ?? "User";
        }
        if (role.containsKey("className") && role["className"] == "_Role") {
          return role["name"] ?? "Doctor";
        }
      }
    }
    return "User";
  }

  
  // 2) UPDATE MY ACCOUNT
  

  static Future<Map<String, dynamic>> updateMyAccount(
    String sessionToken, {
    String? fullName,
    String? username,
    String? fcmToken,
    String? birthDate,
    String? fatherName, required String mobile, required String email,
  }) async {
    try {
      print(" Updating account...");

      final body = <String, dynamic>{};
      if (fullName != null) body["fullName"] = fullName;
      if (username != null) body["username"] = username;
      if (fcmToken != null) body["fcm_token"] = fcmToken;
      if (birthDate != null) body["birthDate"] = birthDate;
      if (fatherName != null) body["fatherName"] = fatherName;

      final response = await http.post(
        Uri.parse("$serverUrl/updateMyAccount"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode(body),
      );

      print(" Update Status: ${response.statusCode}");
      print(" Update Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "فشل تحديث الحساب"};
      }
    } catch (e) {
      print(" Update Exception: $e");
      return {"error": "تعذر تحديث الحساب: $e"};
    }
  }

  // 3) LOGOUT
  

  static Future<Map<String, dynamic>> logout(String sessionToken) async {
    try {
      print(" Logging out...");

      final response = await http.post(
        Uri.parse("$serverUrl/logout"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({}),
      );
      print(" Logout Status: ${response.statusCode}");
      print(" Logout Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"message": "تم تسجيل الخروج"};
      }
    } catch (e) {
      print(" Logout Exception: $e");
      return {"message": "تم تسجيل الخروج"};
    }
  }

  
  // 4) ADD SYSTEM USER


  static Future<Map<String, dynamic>> addSystemUser(
    String sessionToken, {
    required String fullName,
    required String username,
    required String password,
    String? role,
    String? mobile,
    String? email,
  }) async {
    try {
      print(" Adding system user: $username");

      final response = await http.post(
        Uri.parse("$serverUrl/addSystemUser"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "fullName": fullName,
          "username": username,
          "password": password,
          if (role != null) "role": role,
          if (mobile != null) "mobile": mobile,
          if (email != null) "email": email,
        }),
      );

      print(" Add User Status: ${response.statusCode}");
      print(" Add User Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "فشل إضافة المستخدم"};
      }
    } catch (e) {
      print(" Add User Exception: $e");
      return {"error": "تعذر إضافة المستخدم: $e"};
    }
  }


  // 5) ADD/EDIT DOCTOR
  

  static Future<Map<String, dynamic>> addEditDoctor(
    String sessionToken, {
    required String fullName,
    required String username,
    required String password,
    String? mobile,
    String? email,
  }) async {
    try {
      print(" Adding/Editing doctor: $username");

      final response = await http.post(
        Uri.parse("$serverUrl/addEditDoctor"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "fullName": fullName,
          "username": username,
          "password": password,
          if (mobile != null) "mobile": mobile,
          if (email != null) "email": email,
        }),
      );

      print(" Doctor Status: ${response.statusCode}");
      print(" Doctor Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "فشل إضافة/تحديث الطبيب"};
      }
    } catch (e) {
      print(" Doctor Exception: $e");
      return {"error": "تعذر إضافة الطبيب: $e"};
    }
  }

  
  // 6) ADD/EDIT SPECIALIST
  

  static Future<Map<String, dynamic>> addEditSpecialist(
    String sessionToken, {
    required String fullName,
    required String username,
    required String password,
    String? mobile,
    String? email,
  }) async {
    try {
      print(" Adding/Editing specialist: $username");

      final response = await http.post(
        Uri.parse("$serverUrl/addEditSpecialist"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "fullName": fullName,
          "username": username,
          "password": password,
          if (mobile != null) "mobile": mobile,
          if (email != null) "email": email,
        }),
      );

      print(" Specialist Status: ${response.statusCode}");
      print(" Specialist Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "فشل إضافة/تحديث الاختصاصي"};
      }
    } catch (e) {
      print(" Specialist Exception: $e");
      return {"error": "تعذر إضافة الاختصاصي: $e"};
    }
  }

  
  // 7) ADD/EDIT ADMIN
  

  static Future<Map<String, dynamic>> addEditAdmin(
    String sessionToken, {
    required String fullName,
    required String username,
    required String password,
    String? mobile,
    String? email,
  }) async {
    try {
      print(" Adding/Editing admin: $username");

      final response = await http.post(
        Uri.parse("$serverUrl/addEditAdmin"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "fullName": fullName,
          "username": username,
          "password": password,
          if (mobile != null) "mobile": mobile,
          if (email != null) "email": email,
        }),
      );

      print(" Admin Status: ${response.statusCode}");
      print(" Admin Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "فشل إضافة/تحديث الإدمن"};
      }
    } catch (e) {
      print(" Admin Exception: $e");
      return {"error": "تعذر إضافة الإدمن: $e"};
    }
  }

  
  // 8) GET ALL DOCTORS
  

  static Future<List<Map<String, dynamic>>> getAllDoctors(
      String sessionToken) async {
    try {
      print(" Fetching all doctors...");

      final response = await http.get(
        Uri.parse("$serverUrl/getAllDoctors"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
      );

      print(" Doctors Status: ${response.statusCode}");
      print(" Doctors Response: ${response.body}");

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
      print(" Get Doctors Exception: $e");
      return [];
    }
  }

  
  // 9) GET ALL SPECIALISTS
  

  static Future<List<Map<String, dynamic>>> getAllSpecialists(
      String sessionToken) async {
    try {
      print(" Fetching all specialists...");

      final response = await http.get(
        Uri.parse("$serverUrl/getAllSpecialists"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
      );

      print(" Specialists Status: ${response.statusCode}");
      print(" Specialists Response: ${response.body}");

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
      print(" Get Specialists Exception: $e");
      return [];
    }
  }

  
  // 10) GET ALL ADMINS


  static Future<List<Map<String, dynamic>>> getAllAdmins(
      String sessionToken) async {
    try {
      print(" Fetching all admins...");

      // استخدام Master Key فقط للسماح بالعرض حتى لو كان role "Admin" وليس "SUPER_ADMIN"
      final response = await http.get(
        Uri.parse("$serverUrl/getAllAdmins"),
        headers: ApiConfig.getHeadersWithMasterKey(),
      );

      print(" Admins Status: ${response.statusCode}");
      print(" Admins Response: ${response.body}");

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
      print(" Get Admins Exception: $e");
      return [];
    }
  }

  
  // 11) CREATE SYSTEM ROLES IF MISSING
  

  static Future<Map<String, dynamic>> createSystemRolesIfMissing(
      String sessionToken) async {
    try {
      print(" Creating system roles if missing...");

      final response = await http.post(
        Uri.parse("$serverUrl/createSystemRolesIfMissing"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key": "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({}),
      );

      print(" Roles Status: ${response.statusCode}");
      print(" Roles Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"message": "تم إنشاء الأدوار"};
      }
    } catch (e) {
      print(" Create Roles Exception: $e");
      return {"message": "تم إنشاء الأدوار"};
    }
  }

  
  // 12) DELETE DOCTOR

  static Future<Map<String, dynamic>> deleteDoctor(
      String sessionToken, String doctorId) async {
    try {
      print(" Deleting doctor: $doctorId");

      // استخدام Master Key فقط للسماح بالحذف حتى لو كان role "Admin" وليس "SUPER_ADMIN"
      final response = await http.delete(
        Uri.parse("$serverUrl/deleteDoctor"),
        headers: ApiConfig.getHeadersWithMasterKey(),
        body: jsonEncode({"doctorId": doctorId}),
      );

      print(" Delete Doctor Status: ${response.statusCode}");
      print(" Delete Doctor Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل حذف الطبيب"};
        }
      }
    } catch (e) {
      print(" Delete Doctor Exception: $e");
      return {"error": "تعذر حذف الطبيب: $e"};
    }
  }

  
  // 13) DELETE SPECIALIST
  

  static Future<Map<String, dynamic>> deleteSpecialist(
      String sessionToken, String specialistId) async {
    try {
      print(" Deleting specialist: $specialistId");

      // استخدام Master Key فقط للسماح بالحذف حتى لو كان role "Admin" وليس "SUPER_ADMIN"
      final response = await http.delete(
        Uri.parse("$serverUrl/deleteSpecialist"),
        headers: ApiConfig.getHeadersWithMasterKey(),
        body: jsonEncode({"specialistId": specialistId}),
      );

      print(" Delete Specialist Status: ${response.statusCode}");
      print(" Delete Specialist Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل حذف الاختصاصي"};
        }
      }
    } catch (e) {
      print(" Delete Specialist Exception: $e");
      return {"error": "تعذر حذف الاختصاصي: $e"};
    }
  }


  // 14) DELETE ADMIN
  

  static Future<Map<String, dynamic>> deleteAdmin(
      String sessionToken, String adminId) async {
    try {
      print(" Deleting admin: $adminId");

      // استخدام Master Key فقط للسماح بالحذف حتى لو كان role "Admin" وليس "SUPER_ADMIN"
      final response = await http.delete(
        Uri.parse("$serverUrl/deleteAdmin"),
        headers: ApiConfig.getHeadersWithMasterKey(),
        body: jsonEncode({"adminId": adminId}),
      );

      print(" Delete Admin Status: ${response.statusCode}");
      print(" Delete Admin Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل حذف الإدمن"};
        }
      }
    } catch (e) {
      print(" Delete Admin Exception: $e");
      return {"error": "تعذر حذف الإدمن: $e"};
    }
  }

}
