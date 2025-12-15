import 'package:flutter/material.dart';
import 'package:pulse_of_sound/api/level_api.dart'; // LevelGameAPI
import 'package:pulse_of_sound/api/child_api.dart'; // ChildLevelAPI
import 'package:shared_preferences/shared_preferences.dart';
import 'StageMapScreen.dart';
import 'utils/child_progress_prefs.dart';

class GroupsScreen extends StatefulWidget {
  final int levelNumber;
  const GroupsScreen({super.key, required this.levelNumber});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<Map<String, dynamic>> groups = [];
  bool isLoading = true;
  int unlockedGroupOrder = 1;

  @override
  void initState() {
    super.initState();
    print(" GroupsScreen Initialized for Level: ${widget.levelNumber}");
    _fetchGroupsAndProgress();
  }

  Future<void> _fetchGroupsAndProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('session_token');
      final childId = prefs.getString('child_id');

      print(" Fetching Level ID for Order: ${widget.levelNumber}");
      final allLevels = await LevelAPI.getAllLevels();
      final currentLevel = allLevels.firstWhere(
        (l) => l['order'] == widget.levelNumber,
        orElse: () => {},
      );

      if (currentLevel.isNotEmpty) {
        final levelId = currentLevel['objectId'];
        print(" Found Level ID: $levelId");
        
        final fetchedGroups = await LevelGameAPI.getLevelGamesForLevel(levelId: levelId);
        fetchedGroups.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
        print(" Fetched ${fetchedGroups.length} Groups");

        if (sessionToken != null && childId != null) {
          final status = await ChildLevelAPI.getCurrentStageForChild(
             sessionToken: sessionToken,
             childId: childId,
          );
           if (status.containsKey('stage')) {
             unlockedGroupOrder = status['stage']['order'] ?? 1;
             print(" Unlocked Group Order: $unlockedGroupOrder");
           }
        }

        if (mounted) {
          setState(() {
            groups = fetchedGroups;
            isLoading = false;
          });
        }
      } else {
        print(" Level not found for order ${widget.levelNumber}");
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      print(" Error fetching groups: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _openGroup(Map<String, dynamic> group) async {
    final groupOrder = group['order'] as int;
    print(" Tapped Group: $groupOrder (Unlocked: $unlockedGroupOrder)");
    
    // التحقق من القفل
    if (groupOrder > unlockedGroupOrder) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إنهاء المجموعة السابقة أولاً")),
      );
      return;
    }

    //  حفظ التقييم
    await ChildProgressPrefs.addDailyEvaluation({
      "date": DateTime.now().toIso8601String(),
      "level": widget.levelNumber,
      "group": groupOrder,
      "stage": 0,
      "event": "فتح مجموعة ${group['name']}",
    });

    if (!mounted) return;
    
    print(" Navigating to StageMapScreen with GroupId: ${group['objectId']}");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StageMapScreen(
          levelNumber: widget.levelNumber,
          groupNumber: groupOrder,
          groupId: group['objectId'], 
        ),
      ),
    );
    
    if (result == true) {
      print(" Returning from StageMapScreen, refreshing...");
      _fetchGroupsAndProgress();
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
          "مجموعات المستوى ${widget.levelNumber}",
          style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: AssetImage("images/levelsBackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : groups.isEmpty 
                ? const Center(child: Text("لا توجد مجموعات متاحة", style: TextStyle(fontSize: 18)))
                : ListView.builder(
                  padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final order = group['order'] as int;
                    final isUnlocked = order <= unlockedGroupOrder;

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
                          group['name'] ?? "مجموعة $order", 
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _openGroup(group),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
