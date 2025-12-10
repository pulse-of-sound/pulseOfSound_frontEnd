import 'package:flutter/material.dart';
import 'utils/child_progress_prefs.dart';

class GroupTestScreen extends StatefulWidget {
  final int levelNumber;
  final int groupNumber;

  const GroupTestScreen({
    super.key,
    required this.levelNumber,
    required this.groupNumber,
  });

  @override
  State<GroupTestScreen> createState() => _GroupTestScreenState();
}

class _GroupTestScreenState extends State<GroupTestScreen> {
  int _score = 0;
  int _currentQuestion = 0;
  bool _submitting = false;

  // مثال أسئلة — استبدلي/وسعي حسب الحاجة
  final List<Map<String, dynamic>> _questions = [
    {
      "question": "ما لون التفاحة؟",
      "options": ["أحمر", "أزرق", "أخضر"],
      "answer": "أحمر",
    },
    {
      "question": "كم عدد أرجل القطة؟",
      "options": ["2", "4", "6"],
      "answer": "4",
    },
    {
      "question": "أي من هذه فاكهة؟",
      "options": ["تفاح", "مِطرَقة", "سيارة"],
      "answer": "تفاح",
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _answer(String selected) async {
    if (_submitting) return;
    final correct = _questions[_currentQuestion]["answer"] as String;
    if (selected == correct) _score++;

    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      await _finishTest();
    }
  }

  Future<void> _finishTest() async {
    setState(() => _submitting = true);

    final evaluation = {
      "date": DateTime.now().toIso8601String(),
      "level": widget.levelNumber,
      "group": widget.groupNumber,
      "stage": -1,
      "event": "اختبار نهاية المجموعة",
      "score": _score,
      "total": _questions.length,
      "feedback": _score / _questions.length >= 0.6
          ? "نجح بالاختبار"
          : "لم ينجح — يحتاج تدريب إضافي",
    };

    await ChildProgressPrefs.addDailyEvaluation(evaluation);

    final passed = _score / _questions.length >= 0.6;

    // عرض نتيجة
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(passed ? "مبروك!" : "حاول مجددًا"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("لقد أجبت على $_score من ${_questions.length}"),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _questions.isEmpty ? 0 : _score / _questions.length,
                  minHeight: 10,
                ),
                const SizedBox(height: 12),
                Text(
                  passed
                      ? "الطفل نجح بالاختبار وتم فتح المجموعة التالية."
                      : "الطفل لم ينجح. جرّب مرة أخرى بعد التدريب.",
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // تغلق الـ dialog
                },
                child: const Text("حسناً"),
              ),
            ],
          ),
        );
      },
    );

    setState(() => _submitting = false);

    // نرجع إلى الشاشة السابقة مع نتيجة النجاح/الفشل
    Navigator.pop(context, passed);
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentQuestion];
    final total = _questions.length;
    final progress = (_currentQuestion + 1) / total;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
        title: Text(
          "اختبار المجموعة ${widget.groupNumber}",
          style: const TextStyle(
            color: Colors.pinkAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/levelsBackground.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                children: [
                  // الهيدر مع تقدم الاختبار
                  Row(
                    children: [
                      Text(
                        "سؤال ${_currentQuestion + 1} من $total",
                        style: const TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        "النتيجة: $_score",
                        style: const TextStyle(
                            color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white70,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // بطاقة السؤال
                  Expanded(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 720),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              q["question"],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            // خيارات
                            ...List<Widget>.from(
                              (q["options"] as List<String>).map(
                                (option) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ElevatedButton(
                                    onPressed: _submitting
                                        ? null
                                        : () => _answer(option),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pinkAccent,
                                      minimumSize:
                                          const Size(double.infinity, 52),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // زر إنهاء مبكر (اختياري)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _submitting
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("انهاء الاختبار"),
                                      content: const Text(
                                          "هل تريد إنهاء الاختبار الآن؟ سيتم تسجيل النتيجة الحالية."),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("إلغاء"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                                context); // close dialog
                                            _finishTest();
                                          },
                                          child: const Text("تأكيد"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.pinkAccent),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "إنهاء الاختبار",
                            style: TextStyle(color: Colors.pinkAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
