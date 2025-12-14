import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/user_api.dart';
import '../../utils/shared_pref_helper.dart';
import 'addChildScreen.dart';
import 'editChildScreen.dart';
import 'modelChild.dart';

class ChildrenPage extends StatefulWidget {
  const ChildrenPage({super.key});

  @override
  State<ChildrenPage> createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  List<Map<String, dynamic>> children = [];
  List<Map<String, dynamic>> filteredChildren = [];
  String searchQuery = "";
  bool _isLoading = false;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // التحقق من الصلاحيات - SuperAdmin و Admin يمكنهم الوصول
    if (!SharedPrefsHelper.hasAdminPermissions()) {
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
    _loadChildren();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    setState(() => _isLoading = true);
    try {
      final sessionToken = SharedPrefsHelper.getToken();
      if (sessionToken != null && sessionToken.isNotEmpty) {
        final childrenList = await UserAPI.getAllChildren(sessionToken);
        setState(() {
          children = childrenList;
          filteredChildren = childrenList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('خطأ في تحميل الأطفال: $e');
    }
  }

  void _filterChildren(String query) {
    final filtered = children.where((child) {
      final nameMatch =
          (child['fullName'] ?? child['name'] ?? '').toString().contains(query);
      final phoneMatch = (child['mobile'] ?? child['parentPhone'] ?? '')
          .toString()
          .contains(query);
      return nameMatch || phoneMatch;
    }).toList();

    setState(() => filteredChildren = filtered);
  }

  void _editChild(int index, dynamic updated) {
    _loadChildren();
  }

  Future<void> _deleteChild(int index) async {
    final childName = filteredChildren[index]['fullName'] ??
        filteredChildren[index]['name'] ??
        'الطفل';
    bool confirm = await _showConfirmDialog(context, childName);
    if (confirm) {
      try {
        final sessionToken = SharedPrefsHelper.getToken();
        final childId = filteredChildren[index]['objectId'] ??
            filteredChildren[index]['id'];

        if (sessionToken != null &&
            sessionToken.isNotEmpty &&
            childId != null) {
          final result = await UserAPI.deleteChild(sessionToken, childId);
          if (!result.containsKey('error')) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('تم حذف الطفل بنجاح'),
                backgroundColor: Colors.green));
            _loadChildren();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(result['error']), backgroundColor: Colors.red));
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _muteChild(int index) async {
    final childName = filteredChildren[index]['fullName'] ??
        filteredChildren[index]['name'] ??
        'الطفل';
    final isMuted = filteredChildren[index]['isMuted'] ?? false;

    bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              isMuted ? "إلغاء كتم الطفل" : "كتم الطفل",
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
            content: Text(isMuted
                ? "هل تريد إلغاء كتم الطفل ($childName)؟"
                : "هل تريد كتم الطفل ($childName)؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text(isMuted ? "إلغاء الكتم" : "كتم"),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        final sessionToken = SharedPrefsHelper.getToken();
        final childId = filteredChildren[index]['objectId'] ??
            filteredChildren[index]['id'];

        if (sessionToken != null &&
            sessionToken.isNotEmpty &&
            childId != null) {
          final result = isMuted
              ? await UserAPI.unmuteChild(sessionToken, childId)
              : await UserAPI.muteChild(sessionToken, childId);

          if (!result.containsKey('error')) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(isMuted
                    ? 'تم إلغاء كتم الطفل بنجاح'
                    : 'تم كتم الطفل بنجاح'),
                backgroundColor: Colors.green));
            _loadChildren();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(result['error']), backgroundColor: Colors.red));
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
      }
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "الأطفال",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 6)
                              ]),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    onChanged: _filterChildren,
                    decoration: InputDecoration(
                      hintText: "ابحث عن طفل...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filteredChildren.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'لا توجد أطفال',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 6),
                        itemCount: filteredChildren.length,
                        itemBuilder: (context, index) {
                          final child = filteredChildren[index];
                          return Card(
                            color: Colors.white.withOpacity(0.88),
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 4,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              leading: const CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.skyBlue,
                                child: Icon(Icons.child_care,
                                    color: Colors.white, size: 28),
                              ),
                              title: Text(
                                child['fullName'] ??
                                    child['name'] ??
                                    'بدون اسم',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              subtitle: Text(
                                "هاتف ولي الأمر: ${child['mobile'] ?? child['parentPhone'] ?? 'غير محدد'}",
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.5,
                                    height: 1.4),
                              ),
                              trailing: SharedPrefsHelper.hasAdminPermissions()
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            (child['isMuted'] ?? false)
                                                ? Icons.volume_off
                                                : Icons.volume_up,
                                            color: (child['isMuted'] ?? false)
                                                ? Colors.orange
                                                : Colors.grey,
                                          ),
                                          onPressed: () => _muteChild(index),
                                          tooltip: (child['isMuted'] ?? false)
                                              ? 'إلغاء كتم'
                                              : 'كتم',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.redAccent),
                                          onPressed: () => _deleteChild(index),
                                        ),
                                      ],
                                    )
                                  : null,
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

  Future<bool> _showConfirmDialog(
      BuildContext context, String childName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              "تأكيد الحذف",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            content: Text("هل تريد حذف الطفل ($childName)؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text("حذف"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
