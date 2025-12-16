import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Colors/colors.dart';
import '../../api/stage_api.dart';
import '../../utils/shared_pref_helper.dart';
import 'addStageQuestionScreen.dart';

class StageQuestionsManagementScreen extends StatefulWidget {
  final String levelGameId;
  final String levelGameName;

  const StageQuestionsManagementScreen({
    super.key,
    required this.levelGameId,
    required this.levelGameName,
  });

  @override
  State<StageQuestionsManagementScreen> createState() => _StageQuestionsManagementScreenState();
}

class _StageQuestionsManagementScreenState extends State<StageQuestionsManagementScreen> {
  List<Map<String, dynamic>> questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final sessionToken = SharedPrefsHelper.getToken();
      if (sessionToken == null) {
        throw 'No session token';
      }

      final questionsList = await StageQuestionAPI.getStageQuestions(
        sessionToken: sessionToken,
        levelGameId: widget.levelGameId,
      );

      setState(() {
        questions = questionsList;
        _isLoading = false;
      });

      if (questionsList.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يوجد أسئلة في هذه المجموعة'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('خطأ في تحميل الأسئلة: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الأسئلة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteQuestion(int index) async {
    final questionId = questions[index]['objectId'];
    bool confirm = await _showConfirmDialog();
    
    if (confirm && questionId != null) {
      try {
        final sessionToken = SharedPrefsHelper.getToken();
        if (sessionToken == null) return;

        final result = await StageQuestionAPI.deleteStageQuestionsByIds(
          sessionToken: sessionToken,
          questionIds: [questionId],
        );

        if (!result.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف السؤال بنجاح'), backgroundColor: Colors.green)
          );
          _loadQuestions();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error']), backgroundColor: Colors.red)
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              "تأكيد الحذف",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            content: const Text("هل تريد حذف هذا السؤال؟"),
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

  String _getQuestionTypeLabel(String? type) {
    switch (type) {
      case 'choose':
        return 'اختيار من متعدد';
      case 'match':
        return 'مطابقة';
      case 'classify':
        return 'تصنيف';
      case 'view_only':
        return 'عرض فقط';
      default:
        return 'غير معروف';
    }
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
                              widget.levelGameName,
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
                              "إدارة الأسئلة",
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

                  // القائمة
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : questions.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا يوجد أسئلة',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: questions.length,
                                itemBuilder: (context, index) {
                                  final question = questions[index];
                                  final questionType = question['question_type'] ?? '';
                                  final instruction = question['instruction'] ?? 'بدون تعليمات';

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
                                              '${index + 1}',
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
                                                  _getQuestionTypeLabel(questionType),
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  instruction,
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
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.redAccent),
                                              onPressed: () => _deleteQuestion(index),
                                              tooltip: 'حذف',
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
                  MaterialPageRoute(
                    builder: (_) => AddStageQuestionScreen(
                      levelGameId: widget.levelGameId,
                      levelGameName: widget.levelGameName,
                    ),
                  ),
                );
                if (result == true) {
                  _loadQuestions();
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
