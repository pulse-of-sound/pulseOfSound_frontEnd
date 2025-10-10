import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import 'editChildScreen.dart';
import 'modelChild.dart';

class ChildrenPage extends StatefulWidget {
  const ChildrenPage({super.key});

  @override
  State<ChildrenPage> createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  List<Child> children = [
    Child(name: "محمد", birthDate: "15/03/2017", parentPhone: "0991111111"),
    Child(name: "سارة", birthDate: "22/09/2016", parentPhone: "0992222222"),
    Child(name: "ليان", birthDate: "10/12/2015", parentPhone: "0993333333"),
  ];

  String searchQuery = "";

  void _editChild(int index, Child updated) {
    setState(() => children[index] = updated);
  }

  void _deleteChild(int index) {
    setState(() => children.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    List<Child> filtered = children
        .where((child) =>
            child.name.contains(searchQuery) ||
            child.parentPhone.contains(searchQuery))
        .toList();

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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // شريط علوي
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

                  // شريط البحث
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
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

                  // القائمة
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 6),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final child = filtered[index];
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
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.skyBlue,
                              child: Icon(Icons.child_care,
                                  color: Colors.white, size: 28),
                            ),
                            title: Text(
                              child.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            subtitle: Text(
                              "تاريخ الميلاد: ${child.birthDate} \n هاتف ولي الأمر: ${child.parentPhone}",
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13.5,
                                  height: 1.4),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blueAccent),
                                  onPressed: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditChildPage(child: child),
                                      ),
                                    );
                                    if (updated != null && updated is Child) {
                                      _editChild(index, updated);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    bool confirm =
                                        await _showConfirmDialog(context);
                                    if (confirm) _deleteChild(index);
                                  },
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
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
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
            content: const Text("هل تريد حذف هذا الطفل؟"),
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
