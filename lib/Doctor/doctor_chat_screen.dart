import 'package:flutter/material.dart';
import 'package:pulse_of_sound/Doctor/utils/doctor_chat_service.dart';
import '../../Colors/colors.dart';

class DoctorChatScreen extends StatefulWidget {
  const DoctorChatScreen({super.key});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  bool showCommunity = false;
  List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final data = showCommunity
        ? await DoctorChatService.loadCommunity()
        : await DoctorChatService.loadPrivate();

    setState(() => messages = List.from(data.reversed)); // الأحدث بالأسفل
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();

    if (showCommunity) {
      await DoctorChatService.addCommunity("طبيب", text);
    } else {
      await DoctorChatService.addPrivate("طبيب", text);
    }

    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 الخلفية
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
                // 🔹 شريط علوي
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "المحادثات",
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
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // 🔹 أزرار التبديل
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSwitchButton("محادثاتي الخاصة", false),
                      const SizedBox(width: 10),
                      _buildSwitchButton("المجتمع", true),
                    ],
                  ),
                ),

                // 🔹 المحادثة
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: Text(
                            "لا توجد رسائل حالياً",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final isMe = msg["sender"] == "طبيب";
                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppColors.skyBlue.withOpacity(0.9)
                                      : Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  msg["text"] ?? "",
                                  style: TextStyle(
                                    color:
                                        isMe ? Colors.white : Colors.grey[800],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // 🔹 إدخال الرسالة
                Container(
                  color: Colors.white.withOpacity(0.9),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "اكتب رسالة...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppColors.skyBlue,
                        radius: 25,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchButton(String text, bool community) {
    final selected = showCommunity == community;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            showCommunity = community;
          });
          _loadMessages();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? AppColors.skyBlue : Colors.white.withOpacity(0.8),
          foregroundColor: selected ? Colors.white : Colors.black87,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: selected ? 6 : 1,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
