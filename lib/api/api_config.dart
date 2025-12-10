/// ملف الإعدادات المشتركة لجميع API calls
class ApiConfig {
  // Base URL - يمكن تغييره حسب البيئة (Development/Production)
  static const String baseUrl = "http://localhost:1337/api/functions";
  
  // Production URL (عند النشر)
  // static const String baseUrl = "https://api.pulseofsound.com/api/functions";
  
  // Parse Server Configuration
  static const String appId = "cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7";
  static const String masterKey = "He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY";
  
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



