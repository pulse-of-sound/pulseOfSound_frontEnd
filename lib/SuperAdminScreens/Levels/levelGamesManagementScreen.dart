import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Colors/colors.dart';
import '../../api/level_api.dart';
import '../../utils/shared_pref_helper.dart';
import 'addLevelGameScreen.dart';
import 'stageQuestionsManagementScreen.dart';

class LevelGamesManagementScreen extends StatefulWidget {
  final String levelId;
  final String levelName;

  const LevelGamesManagementScreen({
    super.key,
    required this.levelId,
    required this.levelName,
  });

  @override
  State<LevelGamesManagementScreen> createState() => _LevelGamesManagementScreenState();
}

class _LevelGamesManagementScreenState extends State<LevelGamesManagementScreen> {
  List<Map<String, dynamic>> games = [];
  List<Map<String, dynamic>> filteredGames = [];
  final TextEditingController searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    try {
      final gamesList = await LevelGameAPI.getLevelGamesForLevel(levelId: widget.levelId);
      
      // ترتيب حسب order
      gamesList.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
      
      setState(() {
        games = gamesList;
        filteredGames = gamesList;
        _isLoading = false;
      });

      if (gamesList.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يوجد مجموعات في هذا المستوى'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('خطأ في تحميل المجموعات: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل المجموعات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterGames(String query) {
    final filtered = games.where((game) {
      final nameMatch = (game['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase());
      final orderMatch = (game['order'] ?? '').toString().contains(query);
      return nameMatch || orderMatch;
    }).toList();

    setState(() => filteredGames = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Admin.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.25)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              widget.levelName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 6),
                                ],
                              ),
                            ),
                            const Text(
                              "إدارة المجموعات",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // البحث
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: TextField(
                        controller: searchController,
                        onChanged: _filterGames,
                        decoration: InputDecoration(
                          hintText: "ابحث باسم المجموعة أو الترتيب...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // القائمة
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : filteredGames.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا يوجد مجموعات',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredGames.length,
                                itemBuilder: (context, index) {
                                  final game = filteredGames[index];
                                  final gameName = game['name'] ?? 'بدون اسم';
                                  final gameOrder = game['order'] ?? 0;

                                  return Card(
                                    color: Colors.white.withOpacity(0.9),
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    elevation: 6,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        // الانتقال لإدارة الأسئلة
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => StageQuestionsManagementScreen(
                                              levelGameId: game['objectId'],
                                              levelGameName: gameName,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: AppColors.skyBlue,
                                              radius: 26,
                                              child: Text(
                                                '$gameOrder',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    gameName,
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "المجموعة رقم $gameOrder",
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.quiz,
                                              color: Colors.pinkAccent,
                                              size: 30,
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // زر الإضافة
      floatingActionButton: SharedPrefsHelper.isAdmin()
          ? FloatingActionButton(
              backgroundColor: AppColors.skyBlue,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddLevelGameScreen(
                      levelId: widget.levelId,
                      levelName: widget.levelName,
                    ),
                  ),
                );
                if (result == true) {
                  _loadGames();
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
