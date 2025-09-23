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
    Child(name: "محمد", age: "7", parentPhone: "0991111111"),
    Child(name: "سارة", age: "6", parentPhone: "0992222222"),
  ];

  // تعديل بيانات الطفل
  void _editChild(int index, Child child) {
    setState(() {
      children[index] = child;
    });
  }

  // حذف طفل
  void _deleteChild(int index) {
    setState(() {
      children.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الأطفال"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          return Card(
            color: AppColors.babyBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.child_care, color: AppColors.skyBlue),
              title: Text(child.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(
                  "العمر: ${child.age} | هاتف ولي الأمر: ${child.parentPhone}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditChildPage(child: child),
                        ),
                      );
                      if (updated != null && updated is Child) {
                        _editChild(index, updated);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteChild(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
