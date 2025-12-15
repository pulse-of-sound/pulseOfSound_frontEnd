import 'package:flutter/material.dart';
import 'package:pulse_of_sound/api/level_api.dart';
import 'package:pulse_of_sound/api/child_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'GroupScreen.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  List<Map<String, dynamic>> levels = [];
  bool isLoading = true;
  String? errorMessage;
  int completedLevelOrder = 0; // لآخر مستوى تم إكماله

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('session_token');
      final childId = prefs.getString('child_id'); // تأكد من حفظ child_id عند الدخول

      // 1. جلب جميع المستويات
      final allLevels = await LevelAPI.getAllLevels();
      
      // 2. جلب تقدم الطفل (اختياري للتحقق من القفل)
      if (sessionToken != null && childId != null) {
        final status = await ChildLevelAPI.getLevelCompletionStatus(
          sessionToken: sessionToken,
          childId: childId,
        );
        if (status.containsKey('current_order')) {
          // نفترض أن رقم المستوى هو نفسه الترتيب
          // هنا نحتاج منطق أدق حسب ما يرجعه الباك إند عن "المستوى" وليس فقط "المرحلة"
          // للتبسيط حالياً سنعتمد على الترتيب
        }
      }

      // ترتيب المستويات
      allLevels.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

      setState(() {
        levels = allLevels;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "تعذر تحميل المستويات: $e";
      });
    }
  }

  void _openLevel(Map<String, dynamic> level) {
    // منطق التحقق من القفل يمكن إضافته هنا
    // حالياً سنسمح بفتح جميع المستويات للتجربة
    
    Navigator.push(
      context,
      MaterialPageRoute(
        // سنحتاج تمرير ID المستوى للشاشة التالية
        builder: (_) => GroupsScreen(levelNumber: level['order']), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.pinkAccent,
        ),
        title: const Text(
          "المستويات",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/levelsBackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView.builder(
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        // منطق القفل (مثال بسيط: المستوى الأول مفتوح دائماً)
                        final isUnlocked = index == 0 || index <= completedLevelOrder; 

                        return Card(
                          color: isUnlocked
                              ? Colors.white.withOpacity(0.85)
                              : Colors.grey.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isUnlocked ? Icons.play_circle_fill : Icons.lock,
                              color: isUnlocked ? Colors.pinkAccent : Colors.grey,
                              size: 28,
                            ),
                            title: Text(
                              level['name'] ?? "مستوى ${level['order']}",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: level['description'] != null
                                ? Text(level['description'], textAlign: TextAlign.right)
                                : null,
                            onTap: () => _openLevel(level),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
