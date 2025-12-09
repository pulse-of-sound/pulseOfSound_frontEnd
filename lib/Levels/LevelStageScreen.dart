import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sharedPrefs.dart';
import 'utils/child_progress_prefs.dart';

class StageGameScreen extends StatefulWidget {
  final int levelNumber;
  final int groupNumber;
  final int stageNumber;

  const StageGameScreen({
    super.key,
    required this.levelNumber,
    required this.groupNumber,
    required this.stageNumber,
  });

  @override
  State<StageGameScreen> createState() => _StageGameScreenState();
}

class _StageGameScreenState extends State<StageGameScreen> {
  bool _completed = false;
  bool _canPlay = true;
  String? _lastPlayDate;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final last = await SharedPrefsHelper.getString(
        "lastPlayDate_Level${widget.levelNumber}_Group${widget.groupNumber}");
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      _lastPlayDate = last;
      _canPlay = last != today;
    });
  }

  Future<void> _finishStage() async {
    if (!_canPlay) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يمكنك لعب مرحلة واحدة فقط يومياً 🎯"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 🔹 حفظ بيانات التقدم العادية
    await SharedPrefsHelper.setString(
      "lastPlayDate_Level${widget.levelNumber}_Group${widget.groupNumber}",
      today,
    );
    await SharedPrefsHelper.setInt(
      "level_${widget.levelNumber}_group_${widget.groupNumber}_stage",
      widget.stageNumber,
    );

    //  حفظ تقييم الطفل لليوم
    await ChildProgressPrefs.addDailyEvaluation({
      "date": DateTime.now().toIso8601String(),
      "level": widget.levelNumber,
      "group": widget.groupNumber,
      "stage": widget.stageNumber,
      "score": 10, // مؤقتًا، ممكن نحط قيمة حسب أداء الطفل
      "feedback": "أداء رائع في هذه المرحلة ",
    });

    setState(() => _completed = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("أحسنت! لقد أنهيت المرحلة ${widget.stageNumber} "),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
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
        title: Text(
          "المرحلة ${widget.stageNumber}",
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.pinkAccent),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/levelsBackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //  Placeholder للّعبة الفعلية
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      " هنا سيتم عرض اللعبة أو النشاط التعليمي",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                ElevatedButton.icon(
                  onPressed: _finishStage,
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white),
                  label: const Text(
                    "إنهاء المرحلة",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                ),

                const SizedBox(height: 20),
                if (!_canPlay)
                  const Text(
                    "لقد لعبت مرحلة اليوم، يمكنك العودة غداً ",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
