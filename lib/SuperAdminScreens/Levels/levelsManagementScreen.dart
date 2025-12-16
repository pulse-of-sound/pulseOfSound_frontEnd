import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Colors/colors.dart';
import '../../api/level_api.dart';
import '../../utils/shared_pref_helper.dart';
import 'addLevelScreen.dart';
import 'levelGamesManagementScreen.dart';

class LevelsManagementScreen extends StatefulWidget {
  const LevelsManagementScreen({super.key});

  @override
  State<LevelsManagementScreen> createState() => _LevelsManagementScreenState();
}

class _LevelsManagementScreenState extends State<LevelsManagementScreen> {
  List<Map<String, dynamic>> levels = [];
  List<Map<String, dynamic>> filteredLevels = [];
  final TextEditingController searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // التحقق من الصلاحيات - Admin أو SuperAdmin
    if (!SharedPrefsHelper.isAdmin() && !SharedPrefsHelper.isSuperAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ليس لديك صلاحية للوصول إلى هذه الصفحة'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    setState(() => _isLoading = true);
    try {
      final levelsList = await LevelAPI.getAllLevels();
      
      // ترتيب حسب order
      levelsList.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
      
      setState(() {
        levels = levelsList;
        filteredLevels = levelsList;
        _isLoading = false;
      });

      if (levelsList.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يوجد مستويات في النظام'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('خطأ في تحميل المستويات: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل المستويات: $e'),
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

  void _filterLevels(String query) {
    final filtered = levels.where((level) {
      final nameMatch = (level['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase());
      final orderMatch = (level['order'] ?? '').toString().contains(query);
      return nameMatch || orderMatch;
    }).toList();

    setState(() => filteredLevels = filtered);
  }

  Future<void> _deleteLevel(int index) async {
    final levelName = filteredLevels[index]['name'] ?? 'المستوى';
    bool confirm = await _showConfirmDialog(levelName);
    if (confirm) {
      try {
        final levelId = filteredLevels[index]['objectId'];
        final sessionToken = SharedPrefsHelper.getToken();
        
        if (levelId != null && sessionToken != null) {
          final result = await LevelAPI.deleteLevel(sessionToken: sessionToken, levelId: levelId);
          if (!result.containsKey('error')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حذف المستوى بنجاح'), backgroundColor: Colors.green)
            );
            _loadLevels();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['error']), backgroundColor: Colors.red)
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<bool> _showConfirmDialog(String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              "تأكيد الحذف",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            content: Text("هل تريد حذف المستوى ($name)؟\n\nتحذير: سيتم حذف جميع المجموعات المرتبطة بهذا المستوى!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "إلغاء",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("حذف"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _viewLevelGames(int index) {
    final level = filteredLevels[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelGamesManagementScreen(
          levelId: level['objectId'],
          levelName: level['name'] ?? 'المستوى ${level['order']}',
        ),
      ),
    );
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
                      const Expanded(
                        child: Text(
                          "إدارة المستويات",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 6),
                            ],
                          ),
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
                        onChanged: _filterLevels,
                        decoration: InputDecoration(
                          hintText: "ابحث باسم المستوى أو الترتيب...",
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
                        : filteredLevels.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا يوجد مستويات',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredLevels.length,
                                itemBuilder: (context, index) {
                                  final level = filteredLevels[index];
                                  final levelName = level['name'] ?? 'بدون اسم';
                                  final levelOrder = level['order'] ?? 0;
                                  final levelDesc = level['description'] ?? '';

                                  return Card(
                                    color: Colors.white.withOpacity(0.9),
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    elevation: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppColors.skyBlue,
                                            radius: 26,
                                            child: Text(
                                              '$levelOrder',
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
                                                  levelName,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                if (levelDesc.isNotEmpty)
                                                  Text(
                                                    levelDesc,
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (SharedPrefsHelper.isAdmin())
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.games,
                                                      color: Colors.green),
                                                  onPressed: () => _viewLevelGames(index),
                                                  tooltip: 'عرض المجموعات',
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.redAccent),
                                                  onPressed: () => _deleteLevel(index),
                                                  tooltip: 'حذف',
                                                ),
                                              ],
                                            ),
                                        ],
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
                  MaterialPageRoute(builder: (_) => const AddLevelScreen()),
                );
                if (result == true) {
                  _loadLevels();
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
