import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../api/stage_api.dart';
import '../../api/api_config.dart';
import '../../utils/shared_pref_helper.dart';

class AddStageQuestionScreen extends StatefulWidget {
  final String levelGameId;
  final String levelGameName;

  const AddStageQuestionScreen({
    super.key,
    required this.levelGameId,
    required this.levelGameName,
  });

  @override
  State<AddStageQuestionScreen> createState() => _AddStageQuestionScreenState();
}

class _AddStageQuestionScreenState extends State<AddStageQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final instructionCtrl = TextEditingController();
  final correctAnswerCtrl = TextEditingController();
  
  String selectedType = 'choose';
  List<String> imageUrls = []; 
  List<Uint8List> selectedImagesBytes = [];
  List<String> options = [];
  bool _isLoading = false;
  bool _isUploadingImage = false;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController optionCtrl = TextEditingController();

  @override
  void dispose() {
    instructionCtrl.dispose();
    correctAnswerCtrl.dispose();
    optionCtrl.dispose();
    super.dispose();
  }

  // اختيار صورة من المعرض
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          selectedImagesBytes.add(bytes);
        });
        
        // رفع الصورة مباشرة
        await _uploadImage(bytes, image.name);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في اختيار الصورة: $e'), backgroundColor: Colors.red)
      );
    }
  }

  
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          selectedImagesBytes.add(bytes);
        });
        
        // رفع الصورة مباشرة
        await _uploadImage(bytes, photo.name);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في التقاط الصورة: $e'), backgroundColor: Colors.red)
      );
    }
  }

  // رفع الصورة للسيرفر
  Future<void> _uploadImage(Uint8List imageBytes, String filename) async {
    setState(() => _isUploadingImage = true);
    
    try {
      // إنشاء اسم ملف فريد
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFilename = '${timestamp}_$filename';
      
      // رفع الصورة باستخدام Parse REST API
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl.replaceAll('/functions', '')}/files/$uniqueFilename'),
        headers: {
          'X-Parse-Application-Id': ApiConfig.applicationId,
          'X-Parse-Master-Key': ApiConfig.masterKeyValue,
          'Content-Type': 'image/jpeg',
        },
        body: imageBytes,
      );

      print(' Upload Status: ${response.statusCode}');
      print(' Upload Response: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final imageUrl = data['url'];
        
        setState(() {
          imageUrls.add(imageUrl);
          _isUploadingImage = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفع الصورة بنجاح'), backgroundColor: Colors.green)
        );
      } else {
        throw 'فشل رفع الصورة: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      print(' Upload Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في رفع الصورة: $e'), backgroundColor: Colors.red)
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImagesBytes.removeAt(index);
      if (index < imageUrls.length) {
        imageUrls.removeAt(index);
      }
    });
  }

  void _addOption() {
    if (optionCtrl.text.trim().isNotEmpty) {
      setState(() {
        options.add(optionCtrl.text.trim());
        optionCtrl.clear();
      });
    }
  }

  void _removeOption(int index) {
    setState(() {
      options.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر مصدر الصورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('الكاميرا'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من البيانات المطلوبة
    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إضافة صورة واحدة على الأقل'))
      );
      return;
    }

    if (selectedType == 'choose' && options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إضافة خيارات للسؤال من نوع "اختيار"'))
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sessionToken = SharedPrefsHelper.getToken();
      if (sessionToken == null || sessionToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على جلسة'))
        );
        setState(() => _isLoading = false);
        return;
      }

      // بناء السؤال
      final question = {
        'question_type': selectedType,
        'instruction': instructionCtrl.text.trim(),
        'images': imageUrls,
      };

      
      if (selectedType == 'choose') {
        
        question['options'] = {
          'labels': options,  
        };
        question['correct_answer'] = {
          'index': int.tryParse(correctAnswerCtrl.text.trim()) ?? 0,  
        };
      } else if (selectedType == 'match' || selectedType == 'classify') {
        question['correct_answer'] = correctAnswerCtrl.text.trim();
      }

      final result = await StageQuestionAPI.addQuestionsToStage(
        sessionToken: sessionToken,
        levelGameId: widget.levelGameId,
        questions: [question],
      );

      setState(() => _isLoading = false);

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة السؤال بنجاح'), backgroundColor: Colors.green)
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Admin.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شريط العنوان
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                widget.levelGameName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                    )
                                  ],
                                ),
                              ),
                              const Text(
                                "إضافة سؤال جديد",
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

                    const SizedBox(height: 20),

                    // نوع السؤال
                    _buildLabel("نوع السؤال"),
                    _buildDropdown(),

                    // التعليمات
                    _buildField("التعليمات", instructionCtrl, required: true, maxLines: 3),

                    // الصور
                    _buildLabel("الصور"),
                    _buildImageSection(),

                    // الخيارات (للأسئلة من نوع choose)
                    if (selectedType == 'choose') ...[
                      _buildLabel("الخيارات"),
                      _buildOptionsSection(),
                      _buildField("رقم الإجابة الصحيحة (0, 1, 2...)", correctAnswerCtrl,
                          required: true, keyboard: TextInputType.number),
                    ],

                    const SizedBox(height: 30),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                      ),
                      onPressed: (_isLoading || _isUploadingImage) ? null : _addQuestion,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "إضافة السؤال",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: _inputBoxDecoration(),
      child: DropdownButtonFormField<String>(
        value: selectedType,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.85),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.white, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: const [
          DropdownMenuItem(value: 'choose', child: Text('اختيار من متعدد')),
          DropdownMenuItem(value: 'match', child: Text('مطابقة')),
          DropdownMenuItem(value: 'classify', child: Text('تصنيف')),
          DropdownMenuItem(value: 'view_only', child: Text('عرض فقط')),
        ],
        onChanged: (value) {
          setState(() {
            selectedType = value!;
          });
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        // زر إضافة صورة
        ElevatedButton.icon(
          onPressed: _isUploadingImage ? null : _showImageSourceDialog,
          icon: _isUploadingImage 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.add_photo_alternate, color: Colors.white),
          label: Text(_isUploadingImage ? 'جاري الرفع...' : 'إضافة صورة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // عرض الصور المختارة
        if (selectedImagesBytes.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: selectedImagesBytes.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        selectedImagesBytes[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (index < imageUrls.length)
                    Positioned(
                      bottom: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('تم الرفع', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: optionCtrl,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: "نص الخيار",
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.85),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addOption,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...options.asMap().entries.map((entry) {
          return Card(
            color: Colors.white.withOpacity(0.9),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text('${entry.key}', style: const TextStyle(color: Colors.white)),
              ),
              title: Text(entry.value),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeOption(entry.key),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool required = false,
      TextInputType keyboard = TextInputType.text,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: _inputBoxDecoration(),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white.withOpacity(0.85),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.white, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: required
              ? (value) => (value == null || value.isEmpty)
                  ? "الرجاء إدخال $label"
                  : null
              : null,
        ),
      ),
    );
  }

  BoxDecoration _inputBoxDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 6,
          offset: Offset(2, 3),
        ),
      ],
    );
  }
}
