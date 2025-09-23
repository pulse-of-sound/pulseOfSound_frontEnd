import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import 'addAdminScreen.dart';
import 'editAdminScreen.dart';
import 'modelAdmin.dart';

// نموذج الأدمن

class AdminsPage extends StatefulWidget {
  const AdminsPage({super.key});

  @override
  State<AdminsPage> createState() => _AdminsPageState();
}

class _AdminsPageState extends State<AdminsPage> {
  List<Admin> admins = [
    Admin(
      name: "أدمن عام",
      phone: "0991111111",
      email: "admin1@test.com",
      password: "1234",
    ),
    Admin(
      name: "مدير النظام",
      phone: "0992222222",
      email: "admin2@test.com",
      password: "5678",
    ),
  ];

  void _addAdmin(Admin admin) {
    setState(() {
      admins.add(admin);
    });
  }

  void _editAdmin(int index, Admin admin) {
    setState(() {
      admins[index] = admin;
    });
  }

  void _deleteAdmin(int index) {
    setState(() {
      admins.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الأدمن"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: admins.length,
        itemBuilder: (context, index) {
          final admin = admins[index];
          return Card(
            color: AppColors.babyBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.admin_panel_settings,
                  color: AppColors.skyBlue),
              title: Text(
                admin.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text("الهاتف: ${admin.phone}\nالبريد: ${admin.email}"),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditAdminPage(admin: admin),
                        ),
                      );
                      if (updated != null && updated is Admin) {
                        _editAdmin(index, updated);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteAdmin(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.skyBlue,
        onPressed: () async {
          final newAdmin = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAdminPage()),
          );
          if (newAdmin != null && newAdmin is Admin) {
            _addAdmin(newAdmin);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
