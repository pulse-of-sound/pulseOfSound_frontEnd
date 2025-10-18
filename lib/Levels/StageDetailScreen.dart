import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sharedPrefs.dart';

class StageDetailScreen extends StatefulWidget {
  final int levelNumber;
  final int groupNumber;
  final int stageNumber;

  const StageDetailScreen({
    super.key,
    required this.levelNumber,
    required this.groupNumber,
    required this.stageNumber,
  });

  @override
  State<StageDetailScreen> createState() => _StageDetailScreenState();
}

class _StageDetailScreenState extends State<StageDetailScreen> {
  bool _isCompleted = false;
  String? _lastPlayDate;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final lastDate = await SharedPrefsHelper.getString(
        "lastPlayDate_Level${widget.levelNumber}_Group${widget.groupNumber}");
    setState(() {
      _lastPlayDate = lastDate;
    });
  }

  bool _canPlayToday() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _lastPlayDate != today;
  }

  Future<void> _markAsCompleted() async {
    await SharedPrefsHelper.setInt(
      "level_${widget.levelNumber}_group_${widget.groupNumber}_stage",
      widget.stageNumber,
    );
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await SharedPrefsHelper.setString(
      "lastPlayDate_Level${widget.levelNumber}_Group${widget.groupNumber}",
      today,
    );

    setState(() => _isCompleted = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🎉 تم إنهاء المرحلة ${widget.stageNumber} بنجاح!"),
        backgroundColor: Colors.pinkAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // فتح المرحلة التالية أو المجموعة
    if (widget.stageNumber == 10) {
      await SharedPrefsHelper.setInt(
          "unlockedGroup_Level${widget.levelNumber}", widget.groupNumber + 1);

      if (widget.groupNumber == 6) {
        await SharedPrefsHelper.setInt(
            "completedLevel", widget.levelNumber + 1);
      }
    }
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
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/levels.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //  محتوى المرحلة (الكرت)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(2, 3),
                      )
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology_rounded,
                          color: Colors.pinkAccent, size: 40),
                      SizedBox(height: 10),
                      Text(
                        " سيتم عرض اللعبة أو النشاط التعليمي ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                //  زر إنهاء المرحلة
                ElevatedButton(
                  onPressed: !_canPlayToday()
                      ? null
                      : () async {
                          await _markAsCompleted();
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: _canPlayToday()
                        ? Colors.pinkAccent
                        : Colors.grey.shade400,
                    elevation: 5,
                  ),
                  child: const Text(
                    "إنهاء المرحلة",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (!_canPlayToday())
                  const Text(
                    "يمكنك لعب مرحلة جديدة غداً ",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
