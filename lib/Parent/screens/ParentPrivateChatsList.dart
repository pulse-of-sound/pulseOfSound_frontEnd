import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import 'ParentPrivateChatRoom.dart';

class ParentPrivateChatsListScreen extends StatelessWidget {
  const ParentPrivateChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {"id": "chat_1", "doctor": "د. أحمد - سلوك", "duration": 30},
      {"id": "chat_2", "doctor": "د. ليلى - نطق", "duration": 45},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/chat_Background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Column(children: [
            Row(children: [
              IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  onPressed: () => Navigator.pop(context)),
              const Expanded(
                child: Text("محادثاتي الخاصة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
              const SizedBox(width: 40),
            ]),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.pink,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(chat["doctor"]),
                      subtitle: Text(
                          "مدة الجلسة: ${chat["duration"]} دقيقة — انقر للدخول"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ParentPrivateChatRoom(
                              chatId: chat["id"],
                              durationMinutes: chat["duration"],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
