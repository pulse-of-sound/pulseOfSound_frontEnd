import 'package:shared_preferences/shared_preferences.dart';

class APIHelpers {
  static String? _cachedSessionToken;
  
  
  static Future<String?> getSessionToken() async {
    
    if (_cachedSessionToken != null && _cachedSessionToken!.isNotEmpty) {
      return _cachedSessionToken;
    }
    
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedSessionToken = prefs.getString('session_token');
      return _cachedSessionToken;
    } catch (e) {
      print(' Error getting session token: $e');
      return null;
    }
  }
  
  
  static Future<void> setSessionToken(String token) async {
    _cachedSessionToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_token', token);
    } catch (e) {
      print(' Error setting session token: $e');
    }
  }
  
  /// Clear session token (call this on logout)
  static Future<void> clearSessionToken() async {
    _cachedSessionToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_token');
    } catch (e) {
      print(' Error clearing session token: $e');
    }
  }
}
