
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

  
  static String get baseUrl => "http://$host/api/functions";

  
  
  
  
  static const String appId = "cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7";
  static const String masterKey = "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY";

  
  static String get applicationId => appId;
  static String get masterKeyValue => masterKey;

  
  static String fixUrlHost(String url) {
    if (url.isEmpty) return url;
    
    
    if (kIsWeb && url.contains("localhost:1337")) {
      final fixed = url.replaceAll("localhost:1337", _devHost);
      print(" fixUrlHost (Web): $url -> $fixed");
      return fixed;
    }
    
    
    if (url.contains("localhost:1337")) {
      final fixed = url.replaceAll("localhost:1337", host);
      print(" fixUrlHost: $url -> $fixed (host: $host)");
      return fixed;
    }
    
    return url;
  }
  

  static Map<String, String> getBaseHeaders() {
    return {
      "Content-Type": "application/json",
      "X-Parse-Application-Id": appId,
      "X-Parse-Master-Key": masterKey,
    };
  }
  

  static Map<String, String> getHeadersWithToken(String sessionToken) {
    return {
      "Content-Type": "application/json",
      "X-Parse-Application-Id": appId,
      "X-Parse-Session-Token": sessionToken,
      "X-Parse-Master-Key": masterKey,
    };
  }
  
  
  static Map<String, String> getHeadersWithMasterKey() {
    return {
      "Content-Type": "application/json",
      "X-Parse-Application-Id": appId,
      "X-Parse-Master-Key": masterKey,
    };
  }
  

  static Map<String, String> getUploadHeaders(String sessionToken) {
    return {
      "X-Parse-Application-Id": appId,
      "X-Parse-Session-Token": sessionToken,
      "X-Parse-Master-Key": masterKey,
    };
  }
}


