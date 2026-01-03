import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_helpers.dart';
import '../api/user_stage_status_api.dart';
import 'StageDetailScreen.dart';
import 'group_test_screen.dart';

class StageMapScreen extends StatefulWidget {
  final int levelNumber;
  final int groupNumber;
  final String groupId;

  const StageMapScreen({
    super.key,
    required this.levelNumber,
    required this.groupNumber,
    required this.groupId,
  });

  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}


class _StageMapScreenState extends State<StageMapScreen> {
  int currentStage = 0;
  String? localLastPlayDate;
  String? globalLastPlayDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print(" StageMapScreen Initialized for Group: ${widget.groupId}, Order: ${widget.groupNumber}");
    _loadProgressFromBackend();
  }

  Future<void> _loadProgressFromBackend() async {
    final prefs = await SharedPreferences.getInstance();
    final childId = prefs.getString('child_id');
    
    if (childId == null) {
      print(' No child_id found - using default progress');
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }
    
    try {
      print(' Loading progress from Backend for group: ${widget.groupId}');
      
      final result = await UserStageStatusAPI.getStageProgressForGroup(
        childId: childId,
        levelGameId: widget.groupId,
      );
      
      setState(() {
        currentStage = result['current_stage'] ?? 0;
        localLastPlayDate = _parseDate(result['last_play_date']);
        globalLastPlayDate = _parseDate(result['global_last_play_date']);
        isLoading = false;
      });
      
      print(' Backend Progress Loaded: Stage $currentStage');
      print(' Last Play (Local): $localLastPlayDate');
      print(' Last Play (Global): $globalLastPlayDate');
    } catch (e) {
      print(' Error loading progress from Backend: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is String) return date;
    if (date is Map && date.containsKey('iso')) {
      return date['iso'] as String?;
    }
    return date.toString();
  }

  bool _canPlayToday() {
    // نعتمد على التاريخ العام إذا وجد لفرض القيد على مستوى التطبيق
    final dateToCheck = globalLastPlayDate ?? localLastPlayDate;
    
    if (dateToCheck == null) return true;
    
    try {
      // تحويل dateToCheck من ISO string إلى DateTime
      // قد يأتي التاريخ بصيغة Parse Object {__type: Date, iso: ...} أو String مباشرة
      String dateStr;
      if (dateToCheck is Map && (dateToCheck as dynamic)['iso'] != null) {
         dateStr = (dateToCheck as dynamic)['iso'].toString();
      } else {
         dateStr = dateToCheck.toString();
      }

      final lastDate = DateTime.parse(dateStr).toLocal(); // Convert to local time
      final today = DateTime.now();
      
      // مقارنة التاريخ فقط (بدون الوقت)
      final lastDateOnly = DateFormat('yyyy-MM-dd').format(lastDate);
      final todayOnly = DateFormat('yyyy-MM-dd').format(today);
      
      print('📅 Checking if can play today:');
      print('   Last Play Date (Check): $lastDateOnly');
      print('   Today: $todayOnly');
      print('📅 Checking if can play today:');
      print('   Last Play Date (Check): $lastDateOnly');
      print('   Today: $todayOnly');
      
      final canPlay = lastDateOnly != todayOnly;
      print('   Can Play: $canPlay');
      
      return canPlay;
    } catch (e) {
      print('❌ Error parsing date: $e');
      return true; // في حالة الخطأ، اسمح باللعب
    }
  }

  void _openStage(int stageNumber) async {
    print(" Tapped on Stage $stageNumber. Current: $currentStage");
    print(" Last Play Date: ${globalLastPlayDate ?? localLastPlayDate}");
    
    if (stageNumber > currentStage + 1) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" يجب إنهاء المرحلة السابقة أولاً"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (stageNumber == currentStage + 1) {
      if (!_canPlayToday()) {
        
        // تحضير تواريخ للعرض للتوضيح
        String lastDateStr = "غير معروف";
        String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        
        try {
           final dateToCheck = globalLastPlayDate ?? localLastPlayDate;
           if (dateToCheck != null) {
              lastDateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(dateToCheck).toLocal());
           }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(" مرحلة واحدة يومياً! \n آخر لعب: $lastDateStr \n اليوم: $todayStr", textAlign: TextAlign.center),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
      print("Opening new stage $stageNumber");
    } else {
      // إعادة لعب مرحلة مكتملة - مسموح دائماً
      print(" Replaying completed stage $stageNumber");
    }

    try {
      // الحصول على Session Token من APIHelpers
      final sessionToken = await APIHelpers.getSessionToken();
      print(' Passing Session Token to StageDetailScreen: ${sessionToken != null ? "Found (${sessionToken.substring(0, 10)}...)" : "Missing"}');
      
      final passed = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StageDetailScreen(
            levelNumber: widget.levelNumber,
            groupNumber: widget.groupNumber,
            stageNumber: stageNumber,
            groupId: widget.groupId,
            isFinalStage: stageNumber == 10,
            sessionToken: sessionToken, 
          ),
        ),
      );

      if (passed == true) {
        _loadProgressFromBackend();
        if (stageNumber == 10) {
           await Future.delayed(const Duration(milliseconds: 500));
           _openGroupTest();
        }
      }
    } catch (e) {
      print(" Error navigating to stage details: $e");
    }
  }

  void _openGroupTest() async {
    
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupTestScreen(
            levelNumber: widget.levelNumber,
            groupNumber: widget.groupNumber,
          ),
        ),
      );
    } catch (e) {
       print(" Error opening group test: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // لون احتياطي
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("خريطة المراحل", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white, // احتياطي
          image: DecorationImage(
            image: AssetImage("images/levelsBackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading 
         ? const Center(child: CircularProgressIndicator())
         : Center(
            child: SingleChildScrollView( 
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: List.generate(10, (i) {
                  final stageNum = i + 1;
                  final isUnlocked = stageNum <= currentStage + 1;
                  final isCompleted = stageNum <= currentStage;
                  
                  Color color = isCompleted ? Colors.pinkAccent : (isUnlocked ? Colors.orangeAccent : Colors.grey.withOpacity(0.6));
                  
                  return GestureDetector(
                    onTap: () => _openStage(stageNum),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
                      ),
                      child: Center(
                        child: isUnlocked
                            ? Text("$stageNum", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                            : const Icon(Icons.lock, color: Colors.white),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ),
      ),
    );
  }
}
