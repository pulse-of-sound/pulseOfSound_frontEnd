import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_config.dart';

class ResearchCategoriesAPI {
  //  إنشاء فئة بحث جديدة - Admin only
  static Future<Map<String, dynamic>> createResearchCategory({
    required String sessionToken,
    required String name,
  }) async {
    try {
      print(" Creating research category: $name");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/createResearchCategory"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({"name": name}),
      );
      
      print(" Category Status: ${response.statusCode}");
      print(" Category Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل إنشاء فئة البحث"};
        }
      }
    } catch (e) {
      print(" Create Category Exception: $e");
      return {"error": "تعذر إنشاء فئة البحث: $e"};
    }
  }
  
  //  جلب جميع فئات البحث
  static Future<List<Map<String, dynamic>>> getAllResearchCategories({
    required String sessionToken,
  }) async {
    try {
      print(" Fetching all research categories");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getAllResearchCategories"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({}),
      );
      
      print(" Categories Status: ${response.statusCode}");
      print(" Categories Response: ${response.body}");
      
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
      print(" Get Categories Exception: $e");
      return [];
    }
  }
}

class ResearchPostsAPI {
  //  إرسال مقال بحثي جديد - Doctor/Specialist only
  static Future<Map<String, dynamic>> submitResearchPost({
    required String sessionToken,
    required String title,
    required String body,
    required String categoryName,
    String? keywords,
    File? document,
  }) async {
    try {
      print(" Submitting research post: $title");
      
      if (document != null) {
        // رفع مع ملف
        final request = http.MultipartRequest(
          'POST',
          Uri.parse("${ApiConfig.baseUrl}/submitResearchPost"),
        );
        
        request.headers.addAll(ApiConfig.getUploadHeaders(sessionToken));
        request.fields['title'] = title;
        request.fields['body'] = body;
        request.fields['category_name'] = categoryName;
        if (keywords != null) request.fields['keywords'] = keywords;
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'document',
            document.path,
            contentType: MediaType('application', 'pdf'),
          ),
        );
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        print(" Post Status: ${response.statusCode}");
        print(" Post Response: ${response.body}");
        
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          try {
            return jsonDecode(response.body);
          } catch (e) {
            return {"error": "فشل إرسال المقال"};
          }
        }
      } else {
        // رفع بدون ملف
        final response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/submitResearchPost"),
          headers: ApiConfig.getHeadersWithToken(sessionToken),
          body: jsonEncode({
            "title": title,
            "body": body,
            "category_name": categoryName,
            if (keywords != null) "keywords": keywords,
          }),
        );
        
        print(" Post Status: ${response.statusCode}");
        print(" Post Response: ${response.body}");
        
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          try {
            return jsonDecode(response.body);
          } catch (e) {
            return {"error": "فشل إرسال المقال"};
          }
        }
      }
    } catch (e) {
      print(" Submit Post Exception: $e");
      return {"error": "تعذر إرسال المقال: $e"};
    }
  }
  
  //  جلب المقالات المعلّقة - Admin only
  static Future<List<Map<String, dynamic>>> getPendingResearchPosts({
    required String sessionToken,
  }) async {
    try {
      print(" Fetching pending research posts");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getPendingResearchPosts"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({}),
      );
      
      print(" Pending Posts Status: ${response.statusCode}");
      print(" Pending Posts Response: ${response.body}");
      
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
      print(" Get Pending Posts Exception: $e");
      return [];
    }
  }
  
  //  الموافقة أو رفض مقال - Admin only
  static Future<Map<String, dynamic>> approveOrRejectPost({
    required String sessionToken,
    required String postId,
    required String action, // "publish" أو "reject"
    String? rejectionReason,
  }) async {
    try {
      print(" Approving/rejecting post: $postId, action=$action");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/approveOrRejectPost"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({
          "post_id": postId,
          "action": action,
          if (rejectionReason != null) "rejection_reason": rejectionReason,
        }),
      );
      
      print(" Approve/Reject Status: ${response.statusCode}");
      print(" Approve/Reject Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"error": "فشل الموافقة/رفض المقال"};
        }
      }
    } catch (e) {
      print(" Approve/Reject Post Exception: $e");
      return {"error": "تعذر الموافقة/رفض المقال: $e"};
    }
  }
  
  //  جلب المقالات المنشورة
  static Future<List<Map<String, dynamic>>> getPublishedResearchPosts() async {
    try {
      print(" Fetching published research posts");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getPublishedResearchPosts"),
        headers: ApiConfig.getBaseHeaders(),
        body: jsonEncode({}),
      );
      
      print(" Published Posts Status: ${response.statusCode}");
      print(" Published Posts Response: ${response.body}");
      
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
      print(" Get Published Posts Exception: $e");
      return [];
    }
  }
  
  //  البحث في المقالات المنشورة
  static Future<List<Map<String, dynamic>>> searchResearchPosts({
    required String query,
  }) async {
    try {
      print(" Searching research posts: $query");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/searchResearchPosts"),
        headers: ApiConfig.getBaseHeaders(),
        body: jsonEncode({"query": query}),
      );
      
      print(" Search Status: ${response.statusCode}");
      print(" Search Response: ${response.body}");
      
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
      print(" Search Posts Exception: $e");
      return [];
    }
  }

  // جلب مقالاتي (خاصة بالطبيب)
  static Future<List<Map<String, dynamic>>> getMyResearchPosts({
    required String sessionToken,
  }) async {
    try {
      print(" Fetching my research posts");

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/getMyResearchPosts"),
        headers: ApiConfig.getHeadersWithToken(sessionToken),
        body: jsonEncode({}),
      );

      print(" My Posts Status: ${response.statusCode}");
      print(" My Posts Response: ${response.body}");

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
      print(" Get My Posts Exception: $e");
      return [];
    }
  }
}






