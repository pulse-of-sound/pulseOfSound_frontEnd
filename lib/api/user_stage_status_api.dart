import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserStageStatusAPI {
  /// جلب تقدم المراحل لمجموعة معينة
  static Future<Map<String, dynamic>> getStageProgressForGroup({
    required String childId,
    required String levelGameId,
  }) async {
    try {
      print(' Fetching stage progress for group: $levelGameId');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/getStageProgressForGroup'),
        headers: ApiConfig.getHeadersWithMasterKey(),
        body: jsonEncode({
          'child_id': childId,
          'level_game_id': levelGameId,
        }),
      );
      
      print(' Progress Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print(' Progress: ${result['current_stage']} stages completed');
        return result;
      }
      
      // إذا فشل، ارجع قيم افتراضية
      return {
        'current_stage': 0,
        'last_play_date': null,
        'completed': false,
      };
    } catch (e) {
      print(' Error fetching progress: $e');
      return {
        'current_stage': 0,
        'last_play_date': null,
        'completed': false,
      };
    }
  }
}
