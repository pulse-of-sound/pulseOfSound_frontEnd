import 'dart:convert';
import 'package:http/http.dart' as http;

// تأكد من تحديث هذا الرابط بناءً على إعدادات الباك إند
const String baseUrl = "http://localhost:1337/api/functions";
const String masterKey = "YOUR_MASTER_KEY"; // استبدل بـ Master Key الخاص بك

void main() async {
  print("🔍 Testing ChildLevel, Level, and LevelGame APIs...\n");
  
  // اختبار 1: جلب جميع المستويات
  await testGetAllLevels();
  
  // اختبار 2: إضافة مستوى جديد (يتطلب Admin)
  // await testAddLevel();
  
  print("\n✅ All tests completed!");
}

// اختبار جلب جميع المستويات
Future<void> testGetAllLevels() async {
  print("📋 Test 1: Get All Levels");
  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/getAllLevels"),
      headers: {
        'Content-Type': 'application/json',
        'X-Parse-Application-Id': 'PulseOfSound',
      },
    );
    
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Success: Found ${data['levels']?.length ?? 0} levels");
    } else {
      print("❌ Failed: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error: $e");
  }
  
  print("");
}

// اختبار إضافة مستوى جديد
Future<void> testAddLevel() async {
  print("➕ Test 2: Add New Level");
  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/addLevelByAdmin"),
      headers: {
        'Content-Type': 'application/json',
        'X-Parse-Application-Id': 'PulseOfSound',
        'X-Parse-Master-Key': masterKey,
      },
      body: jsonEncode({
        "name": "Test Level",
        "description": "This is a test level",
        "order": 999,
      }),
    );
    
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    
    if (response.statusCode == 200) {
      print("✅ Success: Level added");
    } else {
      print("❌ Failed: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error: $e");
  }
  
  print("");
}

// اختبار جلب المرحلة الحالية للطفل
Future<void> testGetCurrentStageForChild(String sessionToken, String childId) async {
  print("🎯 Test 3: Get Current Stage for Child");
  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/getCurrentStageForChild"),
      headers: {
        'Content-Type': 'application/json',
        'X-Parse-Application-Id': 'PulseOfSound',
        'X-Parse-Session-Token': sessionToken,
      },
      body: jsonEncode({
        "child_id": childId,
      }),
    );
    
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Success: Current stage: ${data['stage']}");
    } else {
      print("❌ Failed: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error: $e");
  }
  
  print("");
}

// اختبار جلب مراحل مستوى معين
Future<void> testGetLevelGamesForLevel(String levelId) async {
  print("🎮 Test 4: Get Level Games for Level");
  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/getLevelGamesForLevel"),
      headers: {
        'Content-Type': 'application/json',
        'X-Parse-Application-Id': 'PulseOfSound',
      },
      body: jsonEncode({
        "level_id": levelId,
      }),
    );
    
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Success: Found ${data['stages']?.length ?? 0} stages");
    } else {
      print("❌ Failed: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error: $e");
  }
  
  print("");
}
