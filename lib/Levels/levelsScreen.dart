import 'package:flutter/material.dart';
import 'GroupScreen.dart';
import 'sharedPrefs.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  int completedLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    completedLevel = await SharedPrefsHelper.getInt("completedLevel") ?? 0;
    setState(() {});
  }

  void _openLevel(int levelNumber) {
    if (levelNumber > completedLevel + 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إنهاء المستوى السابق أولاً")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupsScreen(levelNumber: levelNumber),
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
          "المستويات",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              final levelNum = index + 1;
              final isUnlocked = levelNum <= completedLevel + 1;

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
                    "المستوى $levelNum",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () => _openLevel(levelNum),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
