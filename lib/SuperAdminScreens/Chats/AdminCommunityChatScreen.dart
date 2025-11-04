// lib/Admin/screens/admin_community_chat.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Colors/colors.dart';
import '../../Doctor/utils/doctor_chat_prefs.dart';

class AdminCommunityChatScreen extends StatefulWidget {
  const AdminCommunityChatScreen({super.key});

  @override
  State<AdminCommunityChatScreen> createState() =>
      _AdminCommunityChatScreenState();
}

class _AdminCommunityChatScreenState extends State<AdminCommunityChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final data = await DoctorChatService.loadCommunity();
    setState(() => messages = data);
    // بعد تحميل الرسائل، انزلي تلقائياً لآخر رسالة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage({String? imagePath}) async {
    final text = _controller.text.trim();
    if (text.isEmpty && imagePath == null) return;

    await DoctorChatService.addCommunity("الإدارة", text, imagePath: imagePath);
    _controller.clear();
    await _loadMessages();
    // بعد تحميل الرسائل، انزلي تلقائياً لآخر رسالة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) await _sendMessage(imagePath: picked.path);
  }

  Future<void> _deleteMessage(String id) async {
    await DoctorChatService.deleteMessage(id);
    await _loadMessages();
  }

  Future<void> _banUser(String sender) async {
    await DoctorChatService.banUser(sender);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم حظر $sender من إرسال الرسائل")),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final sender = msg["sender"] ?? "مستخدم";
    final color = sender == "الإدارة"
        ? AppColors.skyBlue.withOpacity(0.9)
        : Colors.white.withOpacity(0.95);
    final textColor = sender == "الإدارة" ? Colors.white : Colors.black87;

    return Dismissible(
      key: ValueKey(msg["id"]),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteMessage(msg["id"]),
      child: Align(
        alignment:
            sender == "الإدارة" ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم المرسل مع زر الحظر
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sender,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: textColor)),
                  if (sender != "الإدارة")
                    IconButton(
                      icon: const Icon(Icons.block,
                          color: Colors.redAccent, size: 18),
                      onPressed: () => _banUser(sender),
                    ),
                ],
              ),

              const SizedBox(height: 5),

              if (msg["image"] != null && msg["image"] != "")
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: kIsWeb
                      ? Image.network(msg["image"], height: 150)
                      : Image.file(File(msg["image"]),
                          height: 150, fit: BoxFit.cover),
                ),
              if (msg["text"] != null && msg["text"].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(msg["text"], style: TextStyle(color: textColor)),
                ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  msg["time"] != null
                      ? msg["time"].toString().substring(11, 16)
                      : "",
                  style: TextStyle(
                      color: textColor.withOpacity(0.8), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("مجتمع الأهالي",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/Admin.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: topPadding, bottom: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) =>
                  _buildMessageBubble(messages[index]),
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(children: [
              IconButton(
                  icon: const Icon(Icons.image, color: AppColors.skyBlue),
                  onPressed: _pickImage),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                      hintText: "اكتب رسالة...", border: InputBorder.none),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.send, color: AppColors.skyBlue),
                  onPressed: _sendMessage),
            ]),
          ),
        ]),
      ]),
    );
  }
}
