import 'package:flutter/material.dart';
import 'sharedPrefs.dart';
import 'StageMapScreen.dart';
import 'utils/child_progress_prefs.dart';

class GroupsScreen extends StatefulWidget {
  final int levelNumber;
  const GroupsScreen({super.key, required this.levelNumber});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  int unlockedGroup = 1;

  final List<String> groups = [
    "التمييز بين الصبي والبنت",
    "الأسرة",
    "الروضة",
    "الألوان",
    "الأحرف",
    "الأرقام"
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    unlockedGroup = await SharedPrefsHelper.getInt(
            "unlockedGroup_Level${widget.levelNumber}") ??
        1;
    setState(() {});
  }

  Future<void> _openGroup(int index) async {
    if (index + 1 > unlockedGroup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إنهاء المجموعة السابقة أولاً")),
      );
      return;
    }

    //  حفظ التقييم إنو الطفل فتح المجموعة
    await ChildProgressPrefs.addDailyEvaluation({
      "date": DateTime.now().toIso8601String(),
      "level": widget.levelNumber,
      "group": index + 1,
      "stage": 0, // 0 لأنو لسا ما دخل مرحلة معينة
      "event": "فتح مجموعة جديدة",
    });

    if (!mounted) return;
    //  الانتقال إلى شاشة المراحل
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StageMapScreen(
          levelNumber: widget.levelNumber,
          groupNumber: index + 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.pinkAccent,
        ),
        title: Text(
          "مجموعات المستوى ${widget.levelNumber}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/levelsBackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final isUnlocked = index + 1 <= unlockedGroup;

            return Card(
              color: isUnlocked
                  ? Colors.white.withOpacity(0.85)
                  : Colors.grey.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                leading: Icon(
                  isUnlocked ? Icons.play_circle_fill : Icons.lock,
                  color: isUnlocked ? Colors.pinkAccent : Colors.grey,
                ),
                title: Text(
                  groups[index],
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _openGroup(index),
              ),
            );
          },
        ),
      ),
    );
  }
}
