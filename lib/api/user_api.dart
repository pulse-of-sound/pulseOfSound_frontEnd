import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserAPI {
  static final String serverUrl = ApiConfig.baseUrl;
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
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
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
        var sessionToken = data["sessionToken"] ?? "";
        final userId = data["id"] ?? data["objectId"] ?? "";
        final usernameFromResponse = data["username"] ?? "";

        print(" DEBUG loginUser: sessionToken from response = '$sessionToken'");
        print(
            " DEBUG loginUser: sessionToken is empty? ${sessionToken.isEmpty}");
        print(" DEBUG loginUser: sessionToken length = ${sessionToken.length}");
        print(" DEBUG loginUser: userId = '$userId'");
        print(" DEBUG loginUser: username = '$usernameFromResponse'");

        // إذا كان sessionToken فارغاً، حاول الحصول عليه من Parse's login endpoint
        if (sessionToken.isEmpty) {
          print(
              " DEBUG loginUser: sessionToken is empty, fetching from Parse login endpoint...");
          final sessionTokenData =
              await _getSessionTokenFromParseLogin(username, password);
          if (sessionTokenData.containsKey("sessionToken")) {
            sessionToken = sessionTokenData["sessionToken"] ?? "";
            print(
                " DEBUG loginUser: Got sessionToken from Parse login: '$sessionToken'");
          }
        }

        // محاولة جلب الـ role
        var roleData = await _fetchUserRole(userId, sessionToken);
        var role = roleData["role"] ?? "User";

        print(" DEBUG loginUser: Role from _fetchUserRole = '$role'");

        // إذا كان role لا يزال "User"، حاول استنتاجها من username أو userId
        if (role == "User") {
          final lowerUsername = usernameFromResponse.toLowerCase();
          final lowerUserId = userId.toLowerCase();

          // التحقق من username أو userId
          if (lowerUsername.contains("superadmin") ||
              lowerUsername.contains("super_admin") ||
              lowerUserId.contains("superadmin") ||
              lowerUserId.contains("super_admin")) {
            role = "SUPER_ADMIN";
            print(
                " DEBUG loginUser: Detected SUPER_ADMIN from username/userId");
          } else if (lowerUsername.contains("admin") &&
              !lowerUsername.contains("super")) {
            role = "Admin";
            print(" DEBUG loginUser: Detected Admin from username");
          } else if (lowerUsername.contains("doctor") ||
              lowerUsername.contains("dr.")) {
            role = "Doctor";
            print(" DEBUG loginUser: Detected Doctor from username");
          } else if (lowerUsername.contains("specialist")) {
            role = "Specialist";
            print(" DEBUG loginUser: Detected Specialist from username");
          }
        }

        // تطبيع الـ role
        if (role.toUpperCase() == "SUPER_ADMIN" || role == "SuperAdmin") {
          role = "SUPER_ADMIN";
        }

        final fullName = data["fullName"] ?? data["username"] ?? "User";

        print(" DEBUG loginUser: Final role = '$role'");
        print(" DEBUG loginUser: Final sessionToken = '$sessionToken'");
        print(
            " DEBUG loginUser: returning data with sessionToken = '$sessionToken'");

        return {
          ...data,
          "sessionToken": sessionToken,
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

  static Future<Map<String, dynamic>> _getSessionTokenFromParseLogin(
      String username, String password) async {
    try {
      print(" Fetching sessionToken from Parse login endpoint...");

      // استخدام Parse REST API login endpoint directly
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/../login"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
        },
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      print(" Parse login status: ${response.statusCode}");
      print(" Parse login response: ${response.body}");

      if (response.statusCode == 200) {
        final loginData = jsonDecode(response.body);
        final token = loginData["sessionToken"] ?? "";
        print(" Successfully got sessionToken: $token");

        if (token.isNotEmpty) {
          return {"sessionToken": token};
        }
      }

      print(" Failed to get sessionToken from Parse login");
      return {};
    } catch (e) {
      print(" Exception fetching sessionToken: $e");
      return {};
    }
  }

  static Future<Map<String, dynamic>> _fetchUserRole(
      String userId, String sessionToken) async {
    try {
      // محاولة 1: جلب الـ role من user object مع include
      final url = Uri.parse("$serverUrl/../classes/_User/$userId?include=role");
      print(" Fetching role from: $url");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
      );

      print(" Role fetch status: ${response.statusCode}");
      print(" Role data: ${response.body}");

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final role = _extractRole(userData);
        print(" Extracted role: $role");

        // إذا تم العثور على role، أرجعها
        if (role != "User") {
          return {
            "role": role,
            "data": userData,
          };
        }
      }

      // محاولة 2: البحث عن الـ role من خلال Parse Roles API
      try {
        final rolesUrl = Uri.parse("$serverUrl/../roles");
        print(" Fetching roles from: $rolesUrl");

        final rolesResponse = await http.get(
          rolesUrl,
          headers: {
            "Content-Type": "application/json",
            "X-Parse-Application-Id": appId,
            "X-Parse-Master-Key":
                "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
          },
        );

        if (rolesResponse.statusCode == 200) {
          final rolesData = jsonDecode(rolesResponse.body);
          if (rolesData.containsKey("results") &&
              rolesData["results"] is List) {
            final roles = rolesData["results"] as List;

            // البحث عن الـ role الذي يحتوي على هذا المستخدم
            for (var roleObj in roles) {
              if (roleObj is Map && roleObj.containsKey("users")) {
                final users = roleObj["users"];
                if (users is Map && users.containsKey("results")) {
                  final roleUsers = users["results"] as List;
                  for (var user in roleUsers) {
                    if (user is Map &&
                        (user["objectId"] == userId || user["id"] == userId)) {
                      final roleName =
                          roleObj["name"] ?? roleObj["name"] ?? "User";
                      print(" Found role from Roles API: $roleName");
                      return {
                        "role": roleName,
                        "data": {},
                      };
                    }
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        print(" Roles API Exception: $e");
      }

      // محاولة 3: البحث في user object مباشرة عن حقل role
      try {
        final userUrl = Uri.parse("$serverUrl/../classes/_User/$userId");
        final userResponse = await http.get(
          userUrl,
          headers: {
            "Content-Type": "application/json",
            "X-Parse-Application-Id": appId,
            "X-Parse-Session-Token": sessionToken,
            "X-Parse-Master-Key":
                "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
          },
        );

        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);

          // البحث عن role في user object
          if (userData.containsKey("role")) {
            final role = _extractRole(userData);
            if (role != "User") {
              print(" Found role in user object: $role");
              return {
                "role": role,
                "data": userData,
              };
            }
          }

          // البحث عن role في username أو fullName
          final username = userData["username"] ?? "";
          if (username.toLowerCase().contains("superadmin") ||
              username.toLowerCase().contains("super_admin")) {
            print(" Detected SUPER_ADMIN from username");
            return {
              "role": "SUPER_ADMIN",
              "data": userData,
            };
          }
        }
      } catch (e) {
        print(" User object fetch Exception: $e");
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
        // تحويل إلى الصيغة الصحيحة
        if (role.toUpperCase() == "SUPER_ADMIN" || role == "SuperAdmin") {
          return "SUPER_ADMIN";
        }
        return role;
      } else if (role is Map) {
        if (role.containsKey("name")) {
          final roleName = role["name"] ?? "User";
          if (roleName.toUpperCase() == "SUPER_ADMIN" ||
              roleName == "SuperAdmin") {
            return "SUPER_ADMIN";
          }
          return roleName;
        }
        if (role.containsKey("className") && role["className"] == "_Role") {
          final roleName = role["name"] ?? "Doctor";
          if (roleName.toUpperCase() == "SUPER_ADMIN" ||
              roleName == "SuperAdmin") {
            return "SUPER_ADMIN";
          }
          return roleName;
        }
      }
    }

    // البحث في الحقول الأخرى
    if (data.containsKey("username")) {
      final username = data["username"]?.toString().toLowerCase() ?? "";
      if (username.contains("superadmin") || username.contains("super_admin")) {
        return "SUPER_ADMIN";
      }
    }

    return "User";
  }

  // 2) GET MY PROFILE

  static Future<Map<String, dynamic>> getMyProfile(String sessionToken) async {
    try {
      print(" Fetching profile...");

      final response = await http.post(
        Uri.parse("$serverUrl/getMyProfile"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({}),
      );

      print(" Fetch Status: ${response.statusCode}");
      print(" Fetch Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "فشل جلب البيانات"};
      }
    } catch (e) {
      print(" Fetch Exception: $e");
      return {"error": "تعذر جلب البيانات: $e"};
    }
  }

  // 3) UPDATE MY ACCOUNT

  static Future<Map<String, dynamic>> updateMyAccount(
    String sessionToken, {
    String? fullName,
    String? username,
    String? fcmToken,
    String? birthDate,
    String? fatherName,
    Map<String, dynamic>? profilePic,
  }) async {
    try {
      print(" Updating account...");

      final body = <String, dynamic>{};
      if (fullName != null) body["fullName"] = fullName;
      if (username != null) body["username"] = username;
      if (fcmToken != null) body["fcm_token"] = fcmToken;
      if (birthDate != null) body["birthDate"] = birthDate;
      if (fatherName != null) body["fatherName"] = fatherName;
      if (profilePic != null) body["profilePic"] = profilePic;

      final response = await http.post(
        Uri.parse("$serverUrl/updateMyAccount"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
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
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
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
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
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
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
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
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
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
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
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
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
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
      print(" DEBUG getAllAdmins: sessionToken = $sessionToken");
      print(
          " DEBUG getAllAdmins: sessionToken length = ${sessionToken.length}");

      final headers = {
        "Content-Type": "application/json",
        "X-Parse-Application-Id": appId,
        "X-Parse-Session-Token": sessionToken,
        "X-Parse-Master-Key":
            "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
      };

      print(" DEBUG getAllAdmins: headers = $headers");

      final response = await http.get(
        Uri.parse("$serverUrl/getAllAdmins"),
        headers: headers,
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
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
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
      print(" DEBUG deleteDoctor: sessionToken = $sessionToken");
      print(
          " DEBUG deleteDoctor: sessionToken length = ${sessionToken.length}");

      final headers = {
        "Content-Type": "application/json",
        "X-Parse-Application-Id": appId,
        "X-Parse-Session-Token": sessionToken,
        "X-Parse-Master-Key":
            "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
      };

      print(" DEBUG deleteDoctor: headers = $headers");

      final response = await http.delete(
        Uri.parse("$serverUrl/deleteDoctor"),
        headers: headers,
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

      final response = await http.delete(
        Uri.parse("$serverUrl/deleteSpecialist"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
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

  // 17) ADD/EDIT CHILD

  static Future<Map<String, dynamic>> addEditChild(String sessionToken,
      {String? childId,
      required String fullName,
      required String mobile,
      String? email,
      String? fatherName,
      String? birthdate,
      String? gender,
      String? medicalInfo}) async {
    try {
      print(" Adding/editing child: $fullName");

      final body = {
        if (childId != null) "childId": childId,
        "fullName": fullName,
        "mobile": mobile,
        if (email != null && email.isNotEmpty) "email": email,
        if (fatherName != null && fatherName.isNotEmpty)
          "fatherName": fatherName,
        if (birthdate != null && birthdate.isNotEmpty) "birthdate": birthdate,
        if (gender != null && gender.isNotEmpty) "gender": gender,
        if (medicalInfo != null && medicalInfo.isNotEmpty)
          "medicalInfo": medicalInfo,
      };

      final response = await http.post(
        Uri.parse("$serverUrl/addEditChild"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode(body),
      );

      print(" Add/Edit Child Status: ${response.statusCode}");
      print(" Add/Edit Child Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إضافة/تعديل الطفل"};
        }
      }
    } catch (e) {
      print(" Add/Edit Child Exception: $e");
      return {"error": "تعذر إضافة/تعديل الطفل: $e"};
    }
  }

  // // 18) GET ALL CHILDREN
  //

  static Future<List<Map<String, dynamic>>> getAllChildren(
      String sessionToken) async {
    try {
      print(" Fetching all children...");

      final response = await http.get(
        Uri.parse("$serverUrl/getAllChildren"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
      );

      print(" Children Status: ${response.statusCode}");
      print(" Children Response: ${response.body}");

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
      print(" Get Children Exception: $e");
      return [];
    }
  }

  // // 19) DELETE CHILD
  //

  static Future<Map<String, dynamic>> deleteChild(
      String sessionToken, String childId) async {
    try {
      print(" Deleting child: $childId");

      final response = await http.delete(
        Uri.parse("$serverUrl/deleteChild"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({"childId": childId}),
      );

      print(" Delete Child Status: ${response.statusCode}");
      print(" Delete Child Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل حذف الطفل"};
        }
      }
    } catch (e) {
      print(" Delete Child Exception: $e");
      return {"error": "تعذر حذف الطفل: $e"};
    }
  }

  // 20) LOGIN WITH MOBILE

  static Future<Map<String, dynamic>> loginWithMobile(
      String mobileNumber, String otp) async {
    try {
      print(" Logging in with mobile: $mobileNumber");

      final response = await http.post(
        Uri.parse("$serverUrl/loginWithMobile"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Client-Key": "null",
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "mobileNumber": mobileNumber,
          "OTP": otp,
        }),
      );

      print(" Mobile Login Status Code: ${response.statusCode}");
      print(" Mobile Login Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل تسجيل الدخول"};
        }
      }
    } catch (e) {
      print(" Mobile Login Exception: $e");
      return {"error": "تعذر تسجيل الدخول: $e"};
    }
  }

  // 21) ADD SYSTEM USER

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

      final body = {
        "fullName": fullName,
        "username": username,
        "password": password,
        if (role != null) "role": role,
        if (mobile != null) "mobile": mobile,
        if (email != null) "email": email,
      };

      final response = await http.post(
        Uri.parse("$serverUrl/addSystemUser"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode(body),
      );

      print(" Add System User Status: ${response.statusCode}");
      print(" Add System User Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إضافة المستخدم"};
        }
      }
    } catch (e) {
      print(" Add System User Exception: $e");
      return {"error": "تعذر إضافة المستخدم: $e"};
    }
  }

  // 23) DELETE ADMIN

  static Future<Map<String, dynamic>> deleteAdmin(
      String sessionToken, String adminId) async {
    try {
      print(" Deleting admin: $adminId");

      final response = await http.delete(
        Uri.parse("$serverUrl/deleteAdmin"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
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
          return {"error": "فشل حذف المدير"};
        }
      }
    } catch (e) {
      print(" Delete Admin Exception: $e");
      return {"error": "تعذر حذف المدير: $e"};
    }
  }

  // 24) CREATE ROLE

  static Future<Map<String, dynamic>> createRole(
      String sessionToken, String roleName) async {
    try {
      print(" Creating role: $roleName");

      final response = await http.post(
        Uri.parse("$serverUrl/createRole"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "name": roleName,
        }),
      );

      print(" Create Role Status: ${response.statusCode}");
      print(" Create Role Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إنشاء الدور"};
        }
      }
    } catch (e) {
      print(" Create Role Exception: $e");
      return {"error": "تعذر إنشاء الدور: $e"};
    }
  }

  // 25) GET MY CHILD PROFILE

  static Future<Map<String, dynamic>> getMyChildProfile(
      String sessionToken) async {
    try {
      print(" Fetching my child profile...");

      final response = await http.get(
        Uri.parse("$serverUrl/getMyChildProfile"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
      );

      print(" Get My Child Profile Status: ${response.statusCode}");
      print(" Get My Child Profile Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل جلب ملف الطفل"};
        }
      }
    } catch (e) {
      print(" Get My Child Profile Exception: $e");
      return {"error": "تعذر جلب ملف الطفل: $e"};
    }
  }

  // 26) CREATE OR UPDATE CHILD PROFILE

  static Future<Map<String, dynamic>> createOrUpdateChildProfile(
    String childId, {
    String? name,
    String? fatherName,
    String? birthdate,
    String? gender,
    String? medicalInfo,
  }) async {
    try {
      print(" Creating/Updating child profile: $childId");

      final body = {
        "childId": childId,
        if (name != null && name.isNotEmpty) "name": name,
        if (fatherName != null && fatherName.isNotEmpty)
          "fatherName": fatherName,
        if (birthdate != null && birthdate.isNotEmpty) "birthdate": birthdate,
        if (gender != null && gender.isNotEmpty) "gender": gender,
        if (medicalInfo != null && medicalInfo.isNotEmpty)
          "medical_info": medicalInfo,
      };

      final response = await http.post(
        Uri.parse("$serverUrl/createOrUpdateChildProfile"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode(body),
      );

      print(" Create/Update Child Profile Status: ${response.statusCode}");
      print(" Create/Update Child Profile Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إنشاء/تحديث ملف الطفل"};
        }
      }
    } catch (e) {
      print(" Create/Update Child Profile Exception: $e");
      return {"error": "تعذر إنشاء/تحديث ملف الطفل: $e"};
    }
  }

  // 27) GENERATE OTP

  static Future<Map<String, dynamic>> generateOTP(String mobileNumber) async {
    try {
      print(" Generating OTP for: $mobileNumber");

      final response = await http.post(
        Uri.parse("$serverUrl/generateOTP"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "mobileNumber": mobileNumber,
        }),
      );

      print(" Generate OTP Status: ${response.statusCode}");
      print(" Generate OTP Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إرسال OTP"};
        }
      }
    } catch (e) {
      print(" Generate OTP Exception: $e");
      return {"error": "تعذر إرسال OTP: $e"};
    }
  }

  // 28) RESEND OTP

  static Future<Map<String, dynamic>> resendOTP(String mobileNumber) async {
    try {
      print(" Resending OTP for: $mobileNumber");

      final response = await http.post(
        Uri.parse("$serverUrl/resendOTP"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "mobileNumber": mobileNumber,
        }),
      );

      print(" Resend OTP Status: ${response.statusCode}");
      print(" Resend OTP Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إعادة إرسال OTP"};
        }
      }
    } catch (e) {
      print(" Resend OTP Exception: $e");
      return {"error": "تعذر إعادة إرسال OTP: $e"};
    }
  }

  // 29) MUTE/UNMUTE CHILD

  static Future<Map<String, dynamic>> muteChild(
      String sessionToken, String childId) async {
    try {
      print(" Muting child: $childId");

      final response = await http.post(
        Uri.parse("$serverUrl/muteChild"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({"childId": childId}),
      );

      print(" Mute Child Status: ${response.statusCode}");
      print(" Mute Child Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل كتم الطفل"};
        }
      }
    } catch (e) {
      print(" Mute Child Exception: $e");
      return {"error": "تعذر كتم الطفل: $e"};
    }
  }

  static Future<Map<String, dynamic>> unmuteChild(
      String sessionToken, String childId) async {
    try {
      print(" Unmuting child: $childId");

      final response = await http.post(
        Uri.parse("$serverUrl/unmuteChild"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Session-Token": sessionToken,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({"childId": childId}),
      );

      print(" Unmute Child Status: ${response.statusCode}");
      print(" Unmute Child Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إلغاء كتم الطفل"};
        }
      }
    } catch (e) {
      print(" Unmute Child Exception: $e");
      return {"error": "تعذر إلغاء كتم الطفل: $e"};
    }
  }

  // 30) VERIFY OTP

  static Future<Map<String, dynamic>> verifyOTP(
      String mobileNumber, String otp) async {
    try {
      print(" Verifying OTP for: $mobileNumber");

      final response = await http.post(
        Uri.parse("$serverUrl/verifyOTP"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "mobileNumber": mobileNumber,
          "OTP": otp,
        }),
      );

      print(" Verify OTP Status: ${response.statusCode}");
      print(" Verify OTP Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل التحقق من OTP"};
        }
      }
    } catch (e) {
      print(" Verify OTP Exception: $e");
      return {"error": "تعذر التحقق من OTP: $e"};
    }
  }

  // 30) LOGIN AFTER OTP (معلّق/غير مفعّل)

  static Future<Map<String, dynamic>> loginAfterOTP(String mobileNumber) async {
    try {
      print(" Logging in after OTP for: $mobileNumber");

      final response = await http.post(
        Uri.parse("$serverUrl/loginAfterOTP"),
        headers: {
          "Content-Type": "application/json",
          "X-Parse-Application-Id": appId,
          "X-Parse-Master-Key":
              "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY",
        },
        body: jsonEncode({
          "mobileNumber": mobileNumber,
        }),
      );

      print(" Login After OTP Status: ${response.statusCode}");
      print(" Login After OTP Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل تسجيل الدخول"};
        }
      }
    } catch (e) {
      print(" Login After OTP Exception: $e");
      return {"error": "تعذر تسجيل الدخول: $e"};
    }
  }
}
