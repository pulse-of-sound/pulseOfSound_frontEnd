import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sharedPrefs.dart';
import 'StageDetailScreen.dart';

class StageMapScreen extends StatefulWidget {
  final int levelNumber;
  final int groupNumber;

  const StageMapScreen({
    super.key,
    required this.levelNumber,
    required this.groupNumber,
  });

  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> {
  int currentStage = 0;
  String? lastPlayDate;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    currentStage = await SharedPrefsHelper.getInt(
            "level_${widget.levelNumber}_group_${widget.groupNumber}_stage") ??
        0;
    lastPlayDate = await SharedPrefsHelper.getString(
        "lastPlayDate_Level${widget.levelNumber}_Group${widget.groupNumber}");
    setState(() {});
  }

  bool _canPlayToday() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return lastPlayDate != today;
  }

  void _openStage(int stageNumber) {
    if (stageNumber > currentStage + 1) return;

    if (stageNumber == currentStage + 1 && !_canPlayToday()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يمكنك لعب مرحلة واحدة فقط يومياً")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StageDetailScreen(
          levelNumber: widget.levelNumber,
          groupNumber: widget.groupNumber,
          stageNumber: stageNumber,
        ),
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
        title: Text(
          "خريطة المراحل",
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
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: List.generate(10, (i) {
              final isUnlocked = i <= currentStage;
              return GestureDetector(
                onTap: () => _openStage(i + 1),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked
                        ? Colors.pinkAccent
                        : Colors.grey.withOpacity(0.6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isUnlocked
                        ? Text(
                            "${i + 1}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          )
                        : const Icon(Icons.lock, color: Colors.white),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
