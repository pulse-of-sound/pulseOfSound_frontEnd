import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? lastPlayDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print(" StageMapScreen Initialized for Group: ${widget.groupId}, Order: ${widget.groupNumber}");
    _loadLocalProgress();
  }

  Future<void> _loadLocalProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final stageKey = "level_${widget.levelNumber}_group_${widget.groupNumber}_stage";
    final dateKey = "lastPlayDate_Level${widget.levelNumber}_Group${widget.groupNumber}";
    
    currentStage = prefs.getInt(stageKey) ?? 0;
    lastPlayDate = prefs.getString(dateKey);
    
    print(" Local Progress Loaded: Stage $currentStage, LastDate: $lastPlayDate");
    
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  bool _canPlayToday() {
    if (lastPlayDate == null) return true;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return lastPlayDate != today;
  }

  void _openStage(int stageNumber) async {
    print("📢 Tapped on Stage $stageNumber. Current: $currentStage");
    
    // التحقق 1: هل المرحلة مقفلة تماماً؟
    if (stageNumber > currentStage + 1) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🔒 يجب إنهاء المرحلة السابقة أولاً"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // التحقق 2: إذا كانت مرحلة جديدة (لم تُنجز بعد)، تحقق من التاريخ
    if (stageNumber == currentStage + 1) {
      if (!_canPlayToday()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⏰ مرحلة واحدة يومياً! عد غداً لمرحلة جديدة 🌟"),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      print("✅ Opening new stage $stageNumber");
    } else {
      // إعادة لعب مرحلة مكتملة - مسموح دائماً
      print("🔄 Replaying completed stage $stageNumber");
    }

    try {
      final passed = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StageDetailScreen(
            levelNumber: widget.levelNumber,
            groupNumber: widget.groupNumber,
            stageNumber: stageNumber,
            groupId: widget.groupId,
            isFinalStage: stageNumber == 10,
          ),
        ),
      );

      if (passed == true) {
        _loadLocalProgress();
        if (stageNumber == 10) {
           await Future.delayed(const Duration(milliseconds: 500));
           _openGroupTest();
        }
      }
    } catch (e) {
      print("❌ Error navigating to stage details: $e");
    }
  }

  void _openGroupTest() async {
    // ... (نفس المنطق السابق)
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
            child: SingleChildScrollView( // إضافة سكرول تحسباً للشاشات الصغيرة
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
