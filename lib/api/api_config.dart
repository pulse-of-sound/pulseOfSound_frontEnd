/// ملف الإعدادات المشتركة لجميع API calls
library;
import 'package:flutter/foundation.dart';

class ApiConfig {
  
  static const String _devHost = "127.0.0.1:1337"; 
  static const String _emulatorHost = "10.0.2.2:1337"; 
  
  static const String _lanHost = "";

  
  static String get host {
    if (kIsWeb) return _devHost;
    if (_lanHost.isNotEmpty) return _lanHost;
    return _emulatorHost; 
  }

  // Base URL
  static String get baseUrl => "http://$host/api/functions";

  
  // static const String baseUrl = "https://api.pulseofsound.com/api/functions";
  
  // Parse Server Configuration
  static const String appId = "cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7";
  static const String masterKey = "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY";

  // Public getters
  static String get applicationId => appId;
  static String get masterKeyValue => masterKey;

  
  static String fixUrlHost(String url) {
    if (url.isEmpty) return url;
    
    
    if (kIsWeb && url.contains("localhost:1337")) {
      final fixed = url.replaceAll("localhost:1337", _devHost);
      print(" fixUrlHost (Web): $url -> $fixed");
      return fixed;
    }
    
    // على Android Emulator، نحول localhost إلى 10.0.2.2
    if (url.contains("localhost:1337")) {
      final fixed = url.replaceAll("localhost:1337", host);
      print(" fixUrlHost: $url -> $fixed (host: $host)");
      return fixed;
    }
    
    return url;
  }
  
  /// Headers الأساسية لجميع الطلبات
  static Map<String, String> getBaseHeaders() {
    return {
      "Content-Type": "application/json",
      "X-Parse-Application-Id": appId,
    };
  }
  
  /// Headers مع Session Token
  static Map<String, String> getHeadersWithToken(String sessionToken) {
    return {
      "Content-Type": "application/json",
      "X-Parse-Application-Id": appId,
      "X-Parse-Session-Token": sessionToken,
      "X-Parse-Master-Key": masterKey,
    };
  }
  
  /// Headers مع Master Key فقط (للمهام التي لا تحتاج Session Token)
  static Map<String, String> getHeadersWithMasterKey() {
    return {
      "Content-Type": "application/json",
      "X-Parse-Application-Id": appId,
      "X-Parse-Master-Key": masterKey,
    };
  }
  
  /// Headers للرفع (Upload) - multipart/form-data
  static Map<String, String> getUploadHeaders(String sessionToken) {
    return {
      "X-Parse-Application-Id": appId,
      "X-Parse-Session-Token": sessionToken,
      "X-Parse-Master-Key": masterKey,
    };
  }
}


