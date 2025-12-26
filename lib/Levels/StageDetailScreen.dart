import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulse_of_sound/api/level_api.dart';
import 'package:pulse_of_sound/api/stage_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StageDetailScreen extends StatefulWidget {
  final int levelNumber;
  final int groupNumber;
  final int stageNumber;
  final String groupId;
  final bool isFinalStage;
  final String? sessionToken; 

  const StageDetailScreen({
    super.key,
    required this.levelNumber,
    required this.groupNumber,
    required this.stageNumber,
    required this.groupId,
    this.isFinalStage = false,
    this.sessionToken, 
  });

  @override
  State<StageDetailScreen> createState() => _StageDetailScreenState();
}

class _StageDetailScreenState extends State<StageDetailScreen> {
  bool _isLoading = true;
  bool _isWorking = false;
  
  List<Map<String, dynamic>> _questions = [];
  Map<String, dynamic>? _currentQuestion;
  
  bool _answeredCorrectly = false;
  String? _waitMessage;
  String? _sessionToken; 
  
  Map<int, int> _matchPairs = {};
  int? _selectedLeft;
  
  List<int> _boyImages = [];
  List<int> _girlImages = [];
  List<int> _unclassifiedImages = [];

  @override
  void initState() {
    super.initState();
    print(" StageDetailScreen Initialized (Stage: ${widget.stageNumber})");
    _loadSessionToken();
    _fetchQuestions();
  }
  
  Future<void> _loadSessionToken() async {
    // استخدام Session Token من widget إذا كان 
    if (widget.sessionToken != null && widget.sessionToken!.isNotEmpty) {
      setState(() {
        _sessionToken = widget.sessionToken;
        print(' Session Token from widget: Found (${_sessionToken!.substring(0, 10)}...)');
      });
      return;
    }
    
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sessionToken = prefs.getString('session_token');
      print(' Session Token from SharedPreferences: ${_sessionToken != null ? "Found" : "Missing"}');
    });
  }

  Future<void> _fetchQuestions() async {
    print(" _fetchQuestions started...");
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('session_token');
      
      print(" Session Token: ${sessionToken != null ? 'Found' : 'Missing'}");
      print("Calling StageQuestionAPI.getStageQuestions for Group: ${widget.groupId}");
      
      final questions = await StageQuestionAPI.getStageQuestions(
        sessionToken: sessionToken ?? "", 
        levelGameId: widget.groupId,
      );
      
      print(" Questions Received: ${questions.length}");
      
      if (mounted) {
        setState(() {
          _questions = questions;
          _selectQuestionForToday();
          _isLoading = false;
        });
      }
    } catch (e) {
      print(" Error fetching questions: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectQuestionForToday() {
    if (_questions.isEmpty) return;
    final index = (widget.stageNumber - 1) % _questions.length;
    _currentQuestion = _questions[index];
    
    
    final type = _currentQuestion!['question_type'];
    if (type == 'classify') {
      final images = _currentQuestion!['images'] as List?;
      if (images != null) {
        _unclassifiedImages = List.generate(images.length, (i) => i);
      }
    }
  }

  void _checkAnswer(String selectedAnswer, {int? selectedIndex}) {
    if (_currentQuestion == null) return;
    
    final correctAnswer = _currentQuestion!['correct_answer'];
    final type = _currentQuestion!['question_type'];
    bool isCorrect = false;
    
    if (type == 'choose' && correctAnswer is Map) {
      final correctIndex = correctAnswer['index'];
      if (selectedIndex != null && selectedIndex == correctIndex) {
        isCorrect = true;
      }
    } else {
      isCorrect = true;
    }
    
    if (isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" إجابة صحيحة! أحسنت يا بطل!"), backgroundColor: Colors.green),
      );
      setState(() => _answeredCorrectly = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حاول مرة أخرى!"), backgroundColor: Colors.orange),
      );
    }
  }

  void _checkMatchAnswer() {
    if (_currentQuestion == null) return;
    
    final correctAnswer = _currentQuestion!['correct_answer'];
    if (correctAnswer is! Map || !correctAnswer.containsKey('pairs')) return;
    
    final correctPairs = correctAnswer['pairs'] as List;
    bool isCorrect = true;
    
    for (var pair in correctPairs) {
      final left = pair['left'];
      final right = pair['right'];
      if (_matchPairs[left] != right) {
        isCorrect = false;
        break;
      }
    }
    
    if (isCorrect && _matchPairs.length == correctPairs.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" ممتاز! جميع الوصلات صحيحة!"), backgroundColor: Colors.green),
      );
      setState(() => _answeredCorrectly = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" بعض الوصلات خاطئة، حاول مرة أخرى!"), backgroundColor: Colors.orange),
      );
    }
  }

  void _checkClassifyAnswer() {
    if (_currentQuestion == null) return;
    
    final correctAnswer = _currentQuestion!['correct_answer'];
    if (correctAnswer is! Map) return;
    
    final correctBoy = List<int>.from(correctAnswer['boy'] ?? [])..sort();
    final correctGirl = List<int>.from(correctAnswer['girl'] ?? [])..sort();
    final userBoy = List<int>.from(_boyImages)..sort();
    final userGirl = List<int>.from(_girlImages)..sort();
    
    bool isCorrect = correctBoy.toString() == userBoy.toString() && 
                     correctGirl.toString() == userGirl.toString();
    
    if (isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" تصنيف ممتاز!"), backgroundColor: Colors.green),
      );
      setState(() => _answeredCorrectly = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" التصنيف غير صحيح، حاول مرة أخرى!"), backgroundColor: Colors.orange),
      );
    }
  }

  Future<void> _finishStage() async {
    print(' _finishStage called!');
    setState(() => _isWorking = true);

    try {
      print(' Starting to finish stage...');
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      print('Session Token from state: ${_sessionToken != null && _sessionToken!.isNotEmpty ? "Found (${_sessionToken!.substring(0, 10)}...)" : "Missing"}');

      // حفظ النتيجة في قاعدة البيانات
      if (_sessionToken != null && _sessionToken!.isNotEmpty) {
        print(' Saving stage result to database...');
        
        // إنشاء قائمة الإجابات
        final answers = <Map<String, dynamic>>[];
        
        if (_currentQuestion != null) {
          final questionType = _currentQuestion!['question_type'];
          final questionId = _currentQuestion!['objectId'];
          
          // إضافة الإجابة حسب نوع السؤال
          if (questionType == 'choose') {
            answers.add({
              'question_id': questionId,
              'answer_type': 'choose',
              'is_correct': _answeredCorrectly,
            });
          } else if (questionType == 'match') {
            answers.add({
              'question_id': questionId,
              'answer_type': 'match',
              'is_correct': _answeredCorrectly,
              'match_pairs': _matchPairs,
            });
          } else if (questionType == 'classify') {
            answers.add({
              'question_id': questionId,
              'answer_type': 'classify',
              'is_correct': _answeredCorrectly,
              'boy_images': _boyImages,
              'girl_images': _girlImages,
            });
          } else if (questionType == 'view_only') {
            answers.add({
              'question_id': questionId,
              'answer_type': 'view_only',
              'is_correct': true,
            });
          }
        }
        
        
        try {
          
          final prefs = await SharedPreferences.getInstance();
          final childId = prefs.getString('child_id');
          
          if (childId == null) {
            print(' child_id not found in SharedPreferences');
            throw 'child_id not found';
          }
          
          print(' Using child_id: $childId');
          
          final result = await StageResultAPI.submitStageAnswers(
            childId: childId,
            levelGameId: widget.groupId,
            answers: answers,
          );
          
          if (result['success'] == true) {
            print(' Stage result saved successfully');
          } else {
            print(' Failed to save stage result: ${result['error']}');
          }
        } catch (e) {
          print(' Error saving stage result: $e');
        }
      }

      // حفظ التقدم المحلي
      await prefs.setInt("level_${widget.levelNumber}_group_${widget.groupNumber}_stage", widget.stageNumber);
      await prefs.setString("lastPlayDate_Level${widget.levelNumber}_Group${widget.groupNumber}", today);

      if (widget.isFinalStage) {
         final childId = prefs.getString('child_id');
         
         if (_sessionToken != null && childId != null) {
            final result = await LevelGameAPI.advanceOrRepeatStage(
              sessionToken: _sessionToken!,
              childId: childId,
              stageId: widget.groupId,
              passed: true,
            );
            
            if (result['wait'] == true) {
               setState(() => _waitMessage = result['message']);
            } else if (result['advanced'] == true) {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🎉 تهانينا! لقد أنهيت المجموعة بنجاح!")),
               );
            }
         }
      }
      
      if (!mounted) return;
      
      if (_waitMessage == null) {
         Navigator.pop(context, true);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Widget _buildQuestionUI() {
    if (_questions.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 50),
          const SizedBox(height: 10),
          const Text("لم يتم العثور على أسئلة لهذه المرحلة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: _finishStage, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey), child: const Text("إكمال المرحلة (تجريبي)", style: TextStyle(color: Colors.white))),
        ],
      );
    }

    if (_currentQuestion == null) return const SizedBox();

    final type = _currentQuestion!['question_type'] ?? "unknown";
    final instruction = _currentQuestion!['instruction'] ?? "";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.pinkAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
          ),
          child: Text(instruction, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pinkAccent), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 30),

        if (type == 'view_only') _buildViewOnlyUI(),
        if (type == 'choose') _buildChooseUI(),
        if (type == 'match') _buildMatchUI(),
        if (type == 'classify') _buildClassifyUI(),
      ],
    );
  }

  Widget _buildViewOnlyUI() {
    final images = _currentQuestion!['images'] as List?;
    return Column(
      children: [
        if (images != null && images.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.map<Widget>((img) => _buildImageCard(img.toString())).toList(),
            ),
          ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle, size: 28),
          label: const Text("لقد شاهدت الصور", style: TextStyle(fontSize: 20)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 5,
          ),
          onPressed: _answeredCorrectly ? null : () {
            setState(() => _answeredCorrectly = true);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(" أحسنت يا بطل!")));
          },
        )
      ],
    );
  }

  Widget _buildChooseUI() {
    final images = _currentQuestion!['images'] as List?;
    
    return Column(
      children: [
        const Text(" اضغط على الصورة الصحيحة", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        if (images != null && images.isNotEmpty)
          Wrap(
            spacing: 15,
            runSpacing: 15,
            alignment: WrapAlignment.center,
            children: images.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: _answeredCorrectly ? null : () => _checkAnswer("", selectedIndex: entry.key),
                child: _buildImageCard(entry.value.toString(), isClickable: true, size: 180),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildMatchUI() {
    final images = _currentQuestion!['images'] as List?;
    if (images == null || images.length < 4) return const Text("بيانات غير كافية");

    final leftImages = [images[0], images[1]];
    final rightImages = [images[2], images[3]];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: const Text(" اضغط على صورة من اليسار ثم اضغط على ما يناسبها من اليمين", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العمود الأيسر
            Column(
              children: leftImages.asMap().entries.map((entry) {
                final isSelected = _selectedLeft == entry.key;
                final isMatched = _matchPairs.containsKey(entry.key);
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedLeft = entry.key),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : (isMatched ? Colors.green : Colors.pinkAccent),
                        width: isSelected ? 5 : 3,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)] : [],
                    ),
                    child: _buildImageCard(entry.value.toString(), size: 130),
                  ),
                );
              }).toList(),
            ),
            
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Icon(Icons.arrow_forward, size: 40, color: Colors.pinkAccent),
                const SizedBox(height: 60),
                const Icon(Icons.arrow_forward, size: 40, color: Colors.pinkAccent),
              ],
            ),
            
            
            Column(
              children: rightImages.asMap().entries.map((entry) {
                final rightIndex = entry.key + 2;
                final isMatched = _matchPairs.containsValue(rightIndex);
                
                return GestureDetector(
                  onTap: () {
                    if (_selectedLeft != null) {
                      setState(() {
                        _matchPairs[_selectedLeft!] = rightIndex;
                        _selectedLeft = null;
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: isMatched ? Colors.green : Colors.pinkAccent, width: 3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: _buildImageCard(entry.value.toString(), size: 130),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text("تم الوصل: ${_matchPairs.length} من 2", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.done_all, size: 24),
          label: const Text("هل أنهيت الوصل؟ ", style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            elevation: 5,
          ),
          onPressed: _answeredCorrectly || _matchPairs.length < 2 ? null : _checkMatchAnswer,
        ),
      ],
    );
  }

  Widget _buildClassifyUI() {
    final images = _currentQuestion!['images'] as List?;
    if (images == null || images.isEmpty) return const Text("بيانات غير كافية");

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: const Text(" اضغط على الصورة ثم اضغط على المنطقة المناسبة", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 20),
        
        // منطقة الأولاد
        _buildClickableDropZone("أولاد ", Colors.blue, _boyImages, images),
        const SizedBox(height: 15),
        
        // منطقة البنات
        _buildClickableDropZone("بنات ", Colors.pink, _girlImages, images),
        const SizedBox(height: 15),
        
        // الصور غير المصنفة
        if (_unclassifiedImages.isNotEmpty) ...[
          const Text("اضغط على الصورة:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: _unclassifiedImages.map((index) => _buildClickableImage(images[index].toString(), index)).toList(),
          ),
        ],
        
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.star, size: 24),
          label: const Text("انتهيت من التصنيف!", style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            elevation: 5,
          ),
          onPressed: _answeredCorrectly || _unclassifiedImages.isNotEmpty ? null : _checkClassifyAnswer,
        ),
      ],
    );
  }

  
  int? _selectedImageForClassify;

  Widget _buildClickableDropZone(String label, Color color, List<int> targetList, List images) {
    return GestureDetector(
      onTap: () {
        if (_selectedImageForClassify != null) {
          setState(() {
            targetList.add(_selectedImageForClassify!);
            _unclassifiedImages.remove(_selectedImageForClassify!);
            _boyImages.remove(_selectedImageForClassify!);
            _girlImages.remove(_selectedImageForClassify!);
            if (label.contains("أولاد")) {
              _boyImages.add(_selectedImageForClassify!);
            } else {
              _girlImages.add(_selectedImageForClassify!);
            }
            _selectedImageForClassify = null;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(
            color: color, 
            width: _selectedImageForClassify != null ? 4 : 3,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 10),
            if (targetList.isEmpty)
              Container(
                height: 100,
                alignment: Alignment.center,
                child: Text("اضغط هنا بعد اختيار الصورة", style: TextStyle(color: color.withOpacity(0.5), fontSize: 14)),
              )
            else
              Wrap(
                spacing: 10,
                children: targetList.map((index) => _buildImageCard(images[index].toString(), size: 80)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableImage(String imageUrl, int index) {
    final isSelected = _selectedImageForClassify == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImageForClassify = isSelected ? null : index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey,
            width: isSelected ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
          ] : [],
        ),
        child: _buildImageCard(imageUrl, size: 100),
      ),
    );
  }

  Widget _buildDraggableImage(String imageUrl, int index) {
    return Draggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.7, child: _buildImageCard(imageUrl, size: 100)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildImageCard(imageUrl, size: 100)),
      child: _buildImageCard(imageUrl, size: 100),
    );
  }

  Widget _buildImageCard(String imageUrl, {double size = 220, bool isClickable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          border: Border.all(color: isClickable ? Colors.orangeAccent : Colors.pinkAccent, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.network(
            imageUrl, 
            height: size, 
            width: size, 
            fit: BoxFit.contain,
            errorBuilder: (_,__,___) => Container(
              height: size, width: size,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
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
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
        title: Text("المرحلة ${widget.stageNumber}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent, fontSize: 24)),
      ),
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("images/levels.jpg"), fit: BoxFit.cover)),
        child: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
            : Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))]
                      ),
                      child: _buildQuestionUI(),
                    ),
                    const SizedBox(height: 30),

                    if (_answeredCorrectly) ...[
                        const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 80),
                        const SizedBox(height: 10),
                        if (_isWorking)
                          const CircularProgressIndicator()
                        else
                          ElevatedButton(
                            onPressed: _finishStage,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                              backgroundColor: Colors.orangeAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 10,
                            ),
                            child: Text(
                              widget.isFinalStage ? "إنهاء المجموعة " : "المرحلة التالية ",
                              style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                    ],
                    
                    if (_waitMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
                          child: Text(_waitMessage!, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }
}
