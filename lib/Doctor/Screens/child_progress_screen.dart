import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../Colors/colors.dart';
import '../../api/progress_api.dart';
import '../../utils/api_helpers.dart';

class ChildProgressScreen extends StatefulWidget {
  final String childId;
  final String childName;

  const ChildProgressScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends State<ChildProgressScreen> {
  Map<String, dynamic>? stats;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final token = await APIHelpers.getSessionToken();
      if (token.isEmpty) {
        throw Exception('Session token is empty');
      }

      final result = await ProgressAPI.getChildProgress(
        sessionToken: token,
        childId: widget.childId,
      );

      print(' Doctor View - Child Progress Result: $result');

      Map<String, dynamic>? fetchedStats;
      if (result.containsKey('result')) {
        final innerResult = result['result'];
        if (innerResult is Map && innerResult.containsKey('stats')) {
          fetchedStats = innerResult['stats'];
        }
      } else if (result.containsKey('stats')) {
        fetchedStats = result['stats'];
      }

      if (mounted) {
        setState(() {
          stats = fetchedStats;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'فشل تحميل بيانات الطفل: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "تقدم الطفل: ${widget.childName}",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/booking.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.pink))
              : errorMessage != null
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(errorMessage!, textAlign: TextAlign.center),
                      ),
                    )
                  : stats == null
                      ? const Center(
                          child: Text("لا توجد بيانات لهذا الطفل",
                              style: TextStyle(color: Colors.white, fontSize: 18)))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
                          child: Column(
                            children: [
                              _buildStatsCards(),
                              const SizedBox(height: 20),
                              _buildPieChart(),
                              const SizedBox(height: 20),
                              _buildLevelsProgress(),
                              const SizedBox(height: 20),
                              _buildRecentResults(),
                            ],
                          ),
                        ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalGames = stats!['total_games_played'] ?? 0;
    final averageScore = stats!['average_score'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.games,
            title: "الألعاب الملعوبة",
            value: "$totalGames",
            color: AppColors.pink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            title: "معدل الأداء",
            value: "$averageScore%",
            color: AppColors.skyBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final averageScore = (stats!['average_score'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "الأداء العام",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
           color: AppColors.skyBlue,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 70,
                    sections: [
                      PieChartSectionData(
                        color: AppColors.pink,
                        value: averageScore,
                        title: "${averageScore.toInt()}%",
                        radius: 20,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pink,
                        ),
                      ),
                      PieChartSectionData(
                        color: Colors.grey.withOpacity(0.1),
                        value: 100.0 - averageScore,
                        title: "",
                        radius: 20,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events,
                          size: 40, color: AppColors.skyBlue),
                      const SizedBox(height: 8),
                      Text(
                        _getPerformanceLabel(averageScore),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPerformanceLabel(double score) {
    if (score >= 90) return "ميز جداً";
    if (score >= 80) return "ممتاز";
    if (score >= 70) return "جيد جداً";
    if (score >= 60) return "جيد";
    if (score >= 50) return "مقبول";
    return "يحتاج تحسين";
  }

  Widget _buildLevelsProgress() {
    final levelsProgress = stats!['levels_progress'] as Map? ?? {};
    if (levelsProgress.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20)),
        child: const Center(
            child: Text("لم يبدأ الطفل أي مستويات بعد",
                style: TextStyle(color: Colors.black54))),
      );
    }

    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("التقدم في المستويات",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:  AppColors.skyBlue,)),
              const SizedBox(height: 16),
              ...levelsProgress.entries.map((entry) {
                final levelData = entry.value;
                final levelName = levelData['level_title'] ?? 'مستوى';
                final avg = (levelData['average_score'] ?? 0).toDouble();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(levelName,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("${avg.toInt()}%",
                                style: TextStyle(
                                    color: _getColorForScore(avg),
                                    fontWeight: FontWeight.bold)),
                          ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: avg / 100,
                          backgroundColor: Colors.grey.shade200,
                          color: _getColorForScore(avg),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ]));
  }

  Color _getColorForScore(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildRecentResults() {
    final recentResults = stats!['recent_results'] as List? ?? [];
    if (recentResults.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "أحدث النتائج",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...recentResults.map((result) {
          final gameTitle = result['game_title'] ?? 'لعبة';
          final score = result['score'] ?? 0;
          final total = result['total_questions'] ?? 0;
          final dateStr = result['created_at'];
          
          String formattedDate = "";
          if (dateStr != null) {
             try {
               DateTime date;
               if (dateStr is Map && dateStr.containsKey('iso')) {
                 date = DateTime.parse(dateStr['iso']).toLocal();
               } else {
                 date = DateTime.parse(dateStr.toString()).toLocal();
               }
               formattedDate = DateFormat('MM/dd HH:mm').format(date);
             } catch(_) {}
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.babyPink.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.videogame_asset, color: AppColors.pink),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gameTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (formattedDate.isNotEmpty)
                        Text(formattedDate,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(
                     color: (score == total) ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text("$score/$total", 
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       color: (score == total) ? Colors.green : Colors.orange,
                     ),
                   ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
