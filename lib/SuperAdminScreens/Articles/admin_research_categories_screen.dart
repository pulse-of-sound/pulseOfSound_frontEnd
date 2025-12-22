import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/research_api.dart';
import '../../utils/api_helpers.dart';

class AdminResearchCategoriesScreen extends StatefulWidget {
  const AdminResearchCategoriesScreen({super.key});

  @override
  State<AdminResearchCategoriesScreen> createState() => _AdminResearchCategoriesScreenState();
}

class _AdminResearchCategoriesScreenState extends State<AdminResearchCategoriesScreen> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    try {
      final token = await APIHelpers.getSessionToken();
      final cats = await ResearchCategoriesAPI.getAllResearchCategories(sessionToken: token);
      setState(() => categories = cats);
    } catch (e) {
      if (mounted) APIHelpers.showErrorDialog(context, "حدث خطأ أثناء تحميل الفئات: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;

    try {
      final token = await APIHelpers.getSessionToken();
      final result = await ResearchCategoriesAPI.createResearchCategory(
        sessionToken: token,
        name: name,
      );

      if (result.containsKey('error')) {
        if (mounted) APIHelpers.showErrorDialog(context, result['error']);
      } else {
        _categoryController.clear();
        _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تمت إضافة الفئة بنجاح")),
          );
        }
      }
    } catch (e) {
      if (mounted) APIHelpers.showErrorDialog(context, "حدث خطأ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "إدارة فئات البحث",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            hintText: "اسم الفئة الجديدة",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.skyBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                        child: const Text("إضافة"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : categories.isEmpty
                            ? const Center(child: Text("لا توجد فئات حالياً", style: TextStyle(color: Colors.white, fontSize: 18)))
                            : ListView.builder(
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final cat = categories[index];
                                  return Card(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: ListTile(
                                      title: Text(cat['name']),
                                      trailing: const Icon(Icons.category, color: AppColors.skyBlue),
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
    );
  }
}
