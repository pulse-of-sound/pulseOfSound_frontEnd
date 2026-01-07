
library;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Safe Fallback Values (Development)
  static const String _fallbackAppId = "cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7";
  static const String _fallbackRestKey = "DJKIO08exGEkEEe9TV2HfD2rop7OMwBJY3q0JMYP8AERhkW2YI";
  
  // URL Fallbacks based on platform
  static String get _fallbackBaseUrl {
    if (kIsWeb) return "http://127.0.0.1:1337/api";
    return "http://10.0.2.2:1337/api"; // Default Android emulator
  }

  // Getters that read from .env with fallback
  static String get appId => dotenv.env['APP_ID'] ?? _fallbackAppId;
  static String get restKey => dotenv.env['REST_KEY'] ?? _fallbackRestKey;
  
  // The raw API URL (e.g. http://localhost:1337/api) - Used for Parse SDK
  static String get parseApiUrl => dotenv.env['API_BASE_URL'] ?? _fallbackBaseUrl;

  // The Functions URL (e.g. http://localhost:1337/api/functions) - Used by Custom APIs
  static String get baseUrl => "$parseApiUrl/functions";
  
  // Legacy getter for compatibility
  static String get applicationId => appId;

  // Helper to extract host from URL
  static String get host {
    try {
      final uri = Uri.parse(baseUrl);
      return "${uri.host}:${uri.port}";
    } catch (e) {
      return "localhost:1337";
    }
  }

  static String fixUrlHost(String url) {
    if (url.isEmpty) return url;
    
    // If the URL is relative, prepend base URL logic
    if (!url.startsWith('http')) {
      final baseUri = Uri.parse(baseUrl);
      // Remove /api from base URL if present to get root
      final rootUrl = "${baseUri.scheme}://${baseUri.host}:${baseUri.port}";
      if (url.startsWith('/')) {
        return "$rootUrl$url";
      }
      return "$rootUrl/$url";
    }

    // Modern fix: Use the host defined in .env (or fallback)
    if (url.contains("localhost:1337") && !baseUrl.contains("localhost")) {
      final baseUri = Uri.parse(baseUrl);
      final newHost = "${baseUri.host}:${baseUri.port}";
      return url.replaceAll("localhost:1337", newHost);
    }
    
    return url;
  }
  

  static Map<String, String> getBaseHeaders() {
    return {
      "Content-Type": "application/json",
      "X-Parse-Application-Id": appId,
      "X-Parse-REST-API-Key": restKey,
      "X-Parse-Client-Key": restKey,
    };
  }

  static Map<String, String> getHeadersWithToken(String sessionToken) {
    return {
      "Content-Type": "application/json",
      "X-Parse-Application-Id": appId,
      "X-Parse-Session-Token": sessionToken,
      "X-Parse-REST-API-Key": restKey,
      "X-Parse-Client-Key": restKey,
    };
  }

  static Map<String, String> getHeaders() {
    return {
      "Content-Type": "application/json",
      "X-Parse-Application-Id": appId,
      "X-Parse-REST-API-Key": restKey,
      "X-Parse-Client-Key": restKey,
    };
  }

  static Map<String, String> getUploadHeaders(String sessionToken) {
    return {
      "X-Parse-Application-Id": appId,
      "X-Parse-Session-Token": sessionToken,
      "X-Parse-REST-API-Key": restKey,
      "X-Parse-Client-Key": restKey,
    };
  }
}
