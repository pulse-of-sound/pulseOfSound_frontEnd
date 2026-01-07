import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../utils/error_logger.dart';
import 'api_config.dart';

class UserAPI {
  static final String serverUrl = ApiConfig.baseUrl;
  static final String appId = ApiConfig.appId;

  //  LOGIN FUNCTIONS

  static Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    try {
      print(" Logging in Admin/Doctor: $username");
      ErrorLogger.addBreadcrumb(
        message: 'Login attempt',
        category: 'auth',
        data: {'username': username},
      );

      final response = await http.post(
        Uri.parse("$serverUrl/loginUser"),
        headers: ApiConfig.getBaseHeaders(),
        body: jsonEncode({
          "username": username,
          "password": password, // Sensitive, do not log
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

        // إذا كان sessionToken فارغاً، حاول الحصول عليه من 
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

        // التحقق من وجود الدور في الاستجابة أولاً
        String role = "User";
        if (data.containsKey("role")) {
          role = _extractRole(data);
          print(" DEBUG loginUser: Role from response = '$role'");
        }

        // إذا لم يتم العثور على الدور أو إذا كان "User"، حاول جلبه
        if (role == "User") {
          var roleData = await _fetchUserRole(userId, sessionToken);
          role = roleData["role"] ?? "User";
          print(" DEBUG loginUser: Role from _fetchUserRole = '$role'");
        }

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

        // ---------------------------------------------------------
        // SENTRY: Set user context on successful login
        // ---------------------------------------------------------
        await ErrorLogger.setUser(
          id: userId,
          username: usernameFromResponse,
          email: data['email'],
        );
        
        ErrorLogger.addBreadcrumb(
          message: 'Login successful',
          category: 'auth',
          data: {'role': role},
        );

        return {
          ...data,
          "sessionToken": sessionToken,
          "role": role,
          "fullName": fullName,
        };
      } else {
        await ErrorLogger.logApiError(
          endpoint: 'loginUser',
          statusCode: response.statusCode,
          error: Exception('Login failed'),
          requestData: {'username': username},
        );
        
        try {
          final errorData = jsonDecode(response.body);
          return {"error": errorData["error"] ?? "خطأ في تسجيل الدخول"};
        } catch (e) {
          return {"error": "خطأ: ${response.statusCode}"};
        }
      }
    } catch (e, stackTrace) {
      print(" Login Exception: $e");
      await ErrorLogger.logError(
        e, 
        stackTrace, 
        context: 'loginUser',
        extra: {'username': username}
      );
      return {"error": "تعذر الاتصال بالسيرفر: $e"};
    }
  }

  static Future<Map<String, dynamic>> _getSessionTokenFromParseLogin(
      String username, String password) async {
    try {
      print(" Fetching sessionToken from Parse login endpoint...");

      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/../login"),
        headers: ApiConfig.getBaseHeaders(),
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
  
      final url = Uri.parse("$serverUrl/../classes/_User/$userId?include=role");
      print(" Fetching role from: $url");

      final response = await http.get(
        url,
        headers: ApiConfig.getHeadersWithToken(sessionToken),
      );

      print(" Role fetch status: ${response.statusCode}");
      print(" Role data: ${response.body}");

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final role = _extractRole(userData);
        print(" Extracted role: $role");

      
        if (role != "User") {
          return {
            "role": role,
            "data": userData,
          };
        }
      }

      
      try {
        final rolesUrl = Uri.parse("$serverUrl/../roles");
        print(" Fetching roles from: $rolesUrl");

        final rolesResponse = await http.get(
          rolesUrl,
          headers: ApiConfig.getBaseHeaders(),
        );

        if (rolesResponse.statusCode == 200) {
          final rolesData = jsonDecode(rolesResponse.body);
          if (rolesData.containsKey("results") &&
              rolesData["results"] is List) {
            final roles = rolesData["results"] as List;

            
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

      
      try {
        final userUrl = Uri.parse("$serverUrl/../classes/_User/$userId");
        final userResponse = await http.get(
          userUrl,
          headers: ApiConfig.getHeadersWithToken(sessionToken),
        );

        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);

          
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
          final roleName = role["name"] ?? "User";
          if (roleName.toUpperCase() == "SUPER_ADMIN" ||
              roleName == "SuperAdmin") {
            return "SUPER_ADMIN";
          }
          return roleName;
        }
      }
    }

  
    if (data.containsKey("username")) {
      final username = data["username"]?.toString().toLowerCase() ?? "";
      if (username.contains("superadmin") || username.contains("super_admin")) {
        return "SUPER_ADMIN";
      }
    }

    return "User";
  }

  

  static Future<Map<String, dynamic>> getMyProfile(String sessionToken) async {
    try {
      print(" Fetching profile...");

      final response = await http.post(
        Uri.parse("$serverUrl/getMyProfile"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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

  

  static Future<Map<String, dynamic>> logout(String sessionToken) async {
    try {
      print(" Logging out...");

      final response = await http.post(
        Uri.parse("$serverUrl/logout"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('error')) {
          return {"error": body['error']};
        }
        return {"error": "فشل إضافة/تحديث الطبيب"};
      }
    } catch (e) {
      print(" Doctor Exception: $e");
      return {"error": "تعذر إضافة الطبيب: $e"};
    }
  }
  

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
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('error')) {
          return {"error": body['error']};
        }
        return {"error": "فشل إضافة/تحديث الاختصاصي"};
      }
    } catch (e) {
      print(" Specialist Exception: $e");
      return {"error": "تعذر إضافة الاختصاصي: $e"};
    }
  }

  

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
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('error')) {
          return {"error": body['error']};
        }
        return {"error": "فشل إضافة/تحديث الإدمن"};
      }
    } catch (e) {
      print(" Admin Exception: $e");
      return {"error": "تعذر إضافة الإدمن: $e"};
    }
  }

  

  static Future<dynamic> getAllDoctors(
      String sessionToken, {int skip = 0, int limit = 1000}) async {
    try {
      print(" Fetching all doctors (skip: $skip, limit: $limit)...");

      // Use POST to send params, or query params if GET is supported
      final response = await http.post(
        Uri.parse("$serverUrl/getAllDoctors"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "skip": skip,
          "limit": limit,
        }),
      );

      print(" Doctors Status: ${response.statusCode}");
      // print(" Doctors Response: ${response.body}"); // Verbose

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle paginated response
        if (data is Map && data.containsKey('results')) {
          return {
            "results": List<Map<String, dynamic>>.from(data['results']),
            "total": data['total'],
            "hasMore": data['hasMore']
          };
        }
        
        // Handle legacy response (direct list)
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

  

  static Future<List<Map<String, dynamic>>> getAllSpecialists(
      String sessionToken) async {
    try {
      print(" Fetching all specialists...");

      final response = await http.get(
        Uri.parse("$serverUrl/getAllSpecialists"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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

  

  static Future<List<Map<String, dynamic>>> getAllAdmins(
      String sessionToken) async {
    try {
      print(" Fetching all admins...");
      print(" DEBUG getAllAdmins: sessionToken = $sessionToken");
      print(
          " DEBUG getAllAdmins: sessionToken length = ${sessionToken.length}");

      final headers = ApiConfig.getHeadersWithToken(sessionToken);

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

  

  static Future<Map<String, dynamic>> createSystemRolesIfMissing(
      String sessionToken) async {
    try {
      print(" Creating system roles if missing...");

      final response = await http.post(
        Uri.parse("$serverUrl/createSystemRolesIfMissing"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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


  static Future<Map<String, dynamic>> deleteDoctor(
      String sessionToken, String doctorId) async {
    try {
      print(" Deleting doctor: $doctorId");
      print(" DEBUG deleteDoctor: sessionToken = $sessionToken");
      print(
          " DEBUG deleteDoctor: sessionToken length = ${sessionToken.length}");

      final headers = ApiConfig.getHeadersWithToken(sessionToken);

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

  

  static Future<Map<String, dynamic>> deleteSpecialist(
      String sessionToken, String specialistId) async {
    try {
      print(" Deleting specialist: $specialistId");

      final response = await http.delete(
        Uri.parse("$serverUrl/deleteSpecialist"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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

  //  ADD/EDIT CHILD

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
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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


  

  static Future<List<Map<String, dynamic>>> getAllChildren(
      String sessionToken) async {
    try {
      print(" Fetching all children...");

      final response = await http.get(
        Uri.parse("$serverUrl/getAllChildren"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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


  

  static Future<Map<String, dynamic>> deleteChild(
      String sessionToken, String childId) async {
    try {
      print(" Deleting child: $childId");

      final response = await http.delete(
        Uri.parse("$serverUrl/deleteChild"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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


  static Future<Map<String, dynamic>> loginWithMobile(
      String mobileNumber, String otp) async {
    try {
      print(" Logging in with mobile: $mobileNumber");

      final response = await http.post(
        Uri.parse("$serverUrl/loginWithMobile"),
        headers: ApiConfig.getBaseHeaders(),
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

  //  ADD SYSTEM USER

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
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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

  //  DELETE ADMIN

  static Future<Map<String, dynamic>> deleteAdmin(
      String sessionToken, String adminId) async {
    try {
      print(" Deleting admin: $adminId");

      final response = await http.delete(
        Uri.parse("$serverUrl/deleteAdmin"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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

  //  CREATE ROLE

  static Future<Map<String, dynamic>> createRole(
      String sessionToken, String roleName) async {
    try {
      print(" Creating role: $roleName");

      final response = await http.post(
        Uri.parse("$serverUrl/createRole"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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

  //  GET MY CHILD PROFILE

  static Future<Map<String, dynamic>> getMyChildProfile(
      String sessionToken) async {
    try {
      print(" Fetching my child profile...");

      final response = await http.get(
        Uri.parse("$serverUrl/getMyChildProfile"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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

  //  CREATE OR UPDATE CHILD PROFILE

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
        headers: ApiConfig.getBaseHeaders(),
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

  //  GENERATE OTP

  static Future<Map<String, dynamic>> generateOTP(String mobileNumber) async {
    try {
      print(" Generating OTP for: $mobileNumber");

      final response = await http.post(
        Uri.parse("$serverUrl/generateOTP"),
        headers: ApiConfig.getBaseHeaders(),
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

  //  RESEND OTP

  static Future<Map<String, dynamic>> resendOTP(String mobileNumber) async {
    try {
      print(" Resending OTP for: $mobileNumber");

      final response = await http.post(
        Uri.parse("$serverUrl/resendOTP"),
        headers: ApiConfig.getBaseHeaders(),
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

  //  MUTE/UNMUTE CHILD

  static Future<Map<String, dynamic>> muteChild(
      String sessionToken, String childId) async {
    try {
      print(" Muting child: $childId");

      final response = await http.post(
        Uri.parse("$serverUrl/muteChild"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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
        headers: ApiConfig.getHeadersWithToken(sessionToken),
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

  //  VERIFY OTP

  static Future<Map<String, dynamic>> verifyOTP(
      String mobileNumber, String otp) async {
    try {
      print(" Verifying OTP for: $mobileNumber");

      final response = await http.post(
        Uri.parse("$serverUrl/verifyOTP"),
        headers: ApiConfig.getBaseHeaders(),
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



  static Future<Map<String, dynamic>> loginAfterOTP(String mobileNumber) async {
    try {
      print(" Logging in after OTP for: $mobileNumber");

      final response = await http.post(
        Uri.parse("$serverUrl/loginAfterOTP"),
        headers: ApiConfig.getBaseHeaders(),
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

  static Future<List<Map<String, dynamic>>> getProvidersByType({
    required String sessionToken,
    required String providerType,
  }) async {
    try {
      print(" Fetching providers of type: $providerType");

      final response = await http.post(
        Uri.parse("$serverUrl/getProvidersByType"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"provider_type": providerType}),
      );

      print(" Providers Status: ${response.statusCode}");
      print(" Providers Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      } else {
        try {
          final error = jsonDecode(response.body);
          print(" Error: ${error['message'] ?? 'Unknown error'}");
        } catch (e) {
          print(" Failed to parse error response");
        }
        return [];
      }
    } catch (e) {
      print(" Get Providers Exception: $e");
      return [];
    }
  }

  // --- Profile Update Methods ---

  static Future<Map<String, dynamic>> uploadFile({
    required Uint8List bytes,
    required String filename,
    required String sessionToken,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final String baseUrl = serverUrl.replaceAll('/functions', '');
      final response = await http.post(
        Uri.parse("$baseUrl/files/$filename"),
        headers: ApiConfig.getUploadHeaders(sessionToken)..addAll({"Content-Type": contentType}),
        body: bytes,
      );

      print(" Upload File Status: ${response.statusCode}");
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Failed to upload file: ${response.body}"};
      }
    } catch (e) {
      print(" Upload File Exception: $e");
      return {"error": "Exception during file upload: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateMyAccount({
    required String sessionToken,
    String? fullName,
    String? username,
    String? birthDate,
    String? fatherName,
    String? gender,
    String? medicalInfo,
    String? mobileNumber,
    String? specialty,
    Map<String, dynamic>? profilePic,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (fullName != null) body["fullName"] = fullName;
      if (username != null) body["username"] = username;
      if (birthDate != null) body["birthDate"] = birthDate;
      if (fatherName != null) body["fatherName"] = fatherName;
      if (gender != null) body["gender"] = gender;
      if (mobileNumber != null) body["mobileNumber"] = mobileNumber;
      if (specialty != null) body["specialty"] = specialty;
      if (medicalInfo != null) body["medical_info"] = medicalInfo;
      if (profilePic != null) body["profilePic"] = profilePic;

      final response = await http.post(
        Uri.parse("$serverUrl/updateMyAccount"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode(body),
      );

      print(" Update Account Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Failed to update account: ${response.body}"};
      }
    } catch (e) {
      print(" Update Account Exception: $e");
      return {"error": "Exception during account update: $e"};
    }
  }
}
