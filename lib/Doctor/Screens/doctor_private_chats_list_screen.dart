import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import 'doctor_chat_room.dart';

class DoctorPrivateChatsListScreen extends StatefulWidget {
  const DoctorPrivateChatsListScreen({super.key});

  @override
  State<DoctorPrivateChatsListScreen> createState() =>
      _DoctorPrivateChatsListScreenState();
}

class _DoctorPrivateChatsListScreenState
    extends State<DoctorPrivateChatsListScreen> {
  final List<Map<String, String>> privateChats = [
    {"parentId": "1", "parentName": "محمد"},
    {"parentId": "2", "parentName": "أحمد"},
    {"parentId": "3", "parentName": "ليان"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/doctorsBackground.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
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
                        "محادثاتي الخاصة",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 6)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: privateChats.length,
                    itemBuilder: (context, index) {
                      final chat = privateChats[index];
                      final parentId = chat["parentId"] ?? "";
                      final parentName = chat["parentName"] ?? "وليّ الأمر";
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.skyBlue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            parentName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              color: AppColors.skyBlue),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorPrivateChatRoom(
                                  parentId: parentId,
                                  parentName: parentName,
                                  durationMinutes: 30,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
