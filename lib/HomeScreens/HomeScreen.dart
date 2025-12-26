import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pulse_of_sound/HomeScreens/drawer.dart';
import '../api/progress_api.dart';
import '../utils/api_helpers.dart';
import '../Colors/colors.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
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
      print(' Session Token: ${token.isEmpty ? "EMPTY!" : token.substring(0, 20)}...');
      print(' Loading progress...');

      if (token.isEmpty) {
        throw Exception('Session token is empty - user not logged in?');
      }

      final result = await ProgressAPI.getChildProgress(
        sessionToken: token,
      );

      print(' Full Result: $result');

      // Parse response
      Map<String, dynamic>? fetchedStats;
      if (result.containsKey('result')) {
        final innerResult = result['result'];
        if (innerResult is Map && innerResult.containsKey('stats')) {
          fetchedStats = innerResult['stats'];
        }
      } else if (result.containsKey('stats')) {
        fetchedStats = result['stats'];
      }

      print(' Parsed Stats: $fetchedStats');

      if (mounted) {
        setState(() {
          stats = fetchedStats;
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'فشل تحميل البيانات: $e';
        });
        print(' Error loading progress: $e');
        print(' Stack trace: $stackTrace');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'تقدم طفلي',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProgress,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/booking.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.pink,
                    strokeWidth: 3,
                  ),
                )
              : errorMessage != null
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage!,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadProgress,
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.pink,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : stats == null
                      ? const Center(
                          child: Text(
                            'لا توجد بيانات',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadProgress,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stats Cards
                                _buildStatsCards(),
                                const SizedBox(height: 20),

                                // Pie Chart
                                _buildPieChart(),
                                const SizedBox(height: 20),

                                // Levels Progress
                                _buildLevelsProgress(),
                                const SizedBox(height: 20),

                                // Recent Results
                                _buildRecentResults(),
                              ],
                            ),
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
            title: "الألعاب",
            value: "$totalGames",
            subtitle: "مكتملة",
            color: AppColors.pink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            title: "المتوسط",
            value: "$averageScore%",
            subtitle: "الدرجات",
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
    required String subtitle,
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
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsProgress() {
    final levelsProgress = stats!['levels_progress'] as Map? ?? {};

    if (levelsProgress.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 48, color: AppColors.skyBlue),
              SizedBox(height: 12),
              Text(
                'لم يبدأ الطفل أي مرحلة بعد',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.skyBlue, size: 24),
              SizedBox(width: 8),
              Text(
                "التقدم في المراحل",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...levelsProgress.entries.map((entry) {
            final levelStats = entry.value;
            return _buildLevelProgressBar(levelStats);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar(Map levelStats) {
    final percentage = (levelStats['average_score'] ?? 0) / 100.0;
    final gamesPlayed = levelStats['games_played'] ?? 0;
    final levelTitle = levelStats['level_title'] ?? 'مرحلة';
    final averageScore = levelStats['average_score'] ?? 0;

    Color progressColor;
    if (percentage >= 0.8) {
      progressColor = Colors.green;
    } else if (percentage >= 0.5) {
      progressColor = AppColors.skyBlue;
    } else {
      progressColor = AppColors.pink;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  levelTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$averageScore%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.videogame_asset, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                "$gamesPlayed ${gamesPlayed == 1 ? 'لعبة' : 'ألعاب'}",
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentResults() {
    final recentResults = stats!['recent_results'] as List? ?? [];

    if (recentResults.isEmpty) {
      return const SizedBox();
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: AppColors.pink, size: 24),
              SizedBox(width: 8),
              Text(
                "آخر النتائج",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentResults.take(5).map((result) {
            return _buildResultItem(result);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildResultItem(Map result) {
    final percentage = result['percentage'] ?? 0;
    final gameTitle = result['game_title'] ?? 'لعبة';
    final levelTitle = result['level_title'] ?? 'مرحلة';
    final score = result['score'] ?? 0;
    final totalQuestions = result['total_questions'] ?? 0;

    Color color;
    if (percentage >= 80) {
      color = Colors.green;
    } else if (percentage >= 50) {
      color = AppColors.skyBlue;
    } else {
      color = AppColors.pink;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$percentage%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  levelTitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "$score/$totalQuestions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final levelsProgress = stats!['levels_progress'] as Map? ?? {};

    if (levelsProgress.isEmpty) {
      return const SizedBox();
    }

    
    int totalGames = 0;
    for (var levelStats in levelsProgress.values) {
      totalGames += (levelStats['games_played'] ?? 0) as int;
    }

    if (totalGames == 0) {
      return const SizedBox();
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart, color: AppColors.pink, size: 24),
              SizedBox(width: 8),
              Text(
                "توزيع الألعاب حسب المراحل",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieSections(levelsProgress, totalGames),
                      centerSpaceRadius: 50,
                      sectionsSpace: 3,
                      borderData: FlBorderData(show: false),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildLegend(levelsProgress, totalGames),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      Map levelsProgress, int totalGames) {
    final colors = [
      AppColors.pink,
      AppColors.skyBlue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    int index = 0;
    return levelsProgress.entries.map((entry) {
      final levelStats = entry.value;
      final gamesPlayed = (levelStats['games_played'] ?? 0) as int;
      final percentage = (gamesPlayed / totalGames * 100).toStringAsFixed(1);
      final color = colors[index % colors.length];
      index++;

      return PieChartSectionData(
        value: gamesPlayed.toDouble(),
        title: '$percentage%',
        color: color,
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: null,
      );
    }).toList();
  }

  List<Widget> _buildLegend(Map levelsProgress, int totalGames) {
    final colors = [
      AppColors.pink,
      AppColors.skyBlue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    int index = 0;
    return levelsProgress.entries.map((entry) {
      final levelStats = entry.value;
      final levelTitle = levelStats['level_title'] ?? 'مرحلة';
      final gamesPlayed = (levelStats['games_played'] ?? 0) as int;
      final color = colors[index % colors.length];
      index++;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    levelTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$gamesPlayed ${gamesPlayed == 1 ? 'لعبة' : 'ألعاب'}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
