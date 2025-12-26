import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/research_api.dart';
import '../../utils/api_helpers.dart';

class DoctorArticlesScreen extends StatefulWidget {
  const DoctorArticlesScreen({super.key});

  @override
  State<DoctorArticlesScreen> createState() => _DoctorArticlesScreenState();
}

class _DoctorArticlesScreenState extends State<DoctorArticlesScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<Map<String, dynamic>> myArticles = [];
  List<Map<String, dynamic>> categories = [];
  String? selectedCategory;
  bool isLoading = true;
  bool isSubmitting = false;
 
  File? selectedFile;
  List<int>? selectedFileBytes;
  String? selectedFileName;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    await Future.wait([
      _loadCategories(),
      _loadArticles(),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> _loadCategories() async {
    try {
      final token = await APIHelpers.getSessionToken();
      final cats = await ResearchCategoriesAPI.getAllResearchCategories(sessionToken: token);
      setState(() {
        categories = cats;
        if (categories.isNotEmpty) {
          selectedCategory = categories.first['name'];
        }
      });
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  Future<void> _loadArticles() async {
    try {
      final token = await APIHelpers.getSessionToken();
      final articles = await ResearchPostsAPI.getMyResearchPosts(sessionToken: token);
      setState(() => myArticles = articles);
    } catch (e) {
      print("Error loading articles: $e");
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          selectedFileName = result.files.single.name;
          if (kIsWeb) {
            selectedFileBytes = result.files.single.bytes;
          } else if (result.files.single.path != null) {
            selectedFile = File(result.files.single.path!);
          }
        });
      }
    } catch (e) {
      print("Error picking file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("فشل اختيار الملف: $e")),
        );
      }
    }
  }

  Future<void> _submitArticle() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    if (title.isEmpty || content.isEmpty || selectedCategory == null) {
      APIHelpers.showErrorDialog(context, "الرجاء ملء جميع الحقول واختيار فئة");
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final token = await APIHelpers.getSessionToken();
      final result = await ResearchPostsAPI.submitResearchPost(
        sessionToken: token,
        title: title,
        body: content,
        categoryName: selectedCategory!,
        document: selectedFile,
        fileBytes: selectedFileBytes,
        fileName: selectedFileName,
      );

      if (result.containsKey('error')) {
        if (mounted) APIHelpers.showErrorDialog(context, result['error']);
      } else {
        titleController.clear();
        contentController.clear();
        setState(() {
          selectedFile = null;
          selectedFileBytes = null;
          selectedFileName = null;
        });
        await _loadArticles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم إرسال المقال للمراجعة")),
          );
        }
      }
    } catch (e) {
      if (mounted) APIHelpers.showErrorDialog(context, "حدث خطأ أثناء إرسال المقال: $e");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/doctorsBackground.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "مقالاتي",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadInitialData,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "عنوان المقال",
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              if (categories.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      hint: const Text("اختر فئة البحث"),
                      items: categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['name'],
                          child: Text(cat['name']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => selectedCategory = val);
                      },
                    ),
                  ),
                )
              else if (!isLoading)
                const Text("لا توجد فئات متاحة حالياً", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "محتوى المقال...",
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              // File Picker UI
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickDocument,
                    icon: const Icon(Icons.attach_file),
                    label: const Text("إرفاق ملف"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.skyBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.skyBlue),
                      )
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (selectedFileName != null)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.description, size: 20, color: AppColors.skyBlue),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                selectedFileName!,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedFile = null;
                                  selectedFileBytes = null;
                                  selectedFileName = null;
                                });
                              },
                              child: const Icon(Icons.close, size: 18, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitArticle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.skyBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: isSubmitting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("إرسال المقال"),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : myArticles.isEmpty
                    ? const Center(
                        child: Text("لم ترسل أي مقالات بعد",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)))
                    : ListView.builder(
                        itemCount: myArticles.length,
                        itemBuilder: (context, index) {
                          final a = myArticles[index];
                          final status = a["status"];
                          return Card(
                            color: Colors.white.withOpacity(0.9),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            child: ListTile(
                              title: Text(a["title"]),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("الفئة: ${a["category"]}"),
                                  if (a["document_url"] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          const Text("يوجد مرفق", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    status == "pending"
                                        ? "قيد المراجعة"
                                        : status == "published"
                                            ? "تمت الموافقة والنشر"
                                            : "مرفوض: ${a["rejection_reason"] ?? 'بدون سبب'}",
                                    style: TextStyle(
                                      color: status == "published"
                                          ? Colors.green
                                          : status == "rejected"
                                              ? Colors.red
                                              : Colors.orangeAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
