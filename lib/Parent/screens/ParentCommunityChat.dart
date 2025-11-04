import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Colors/colors.dart';
import '../../Doctor/utils/doctor_chat_prefs.dart';

class ParentCommunityChat extends StatefulWidget {
  const ParentCommunityChat({super.key});

  @override
  State<ParentCommunityChat> createState() => _ParentCommunityChatState();
}

class _ParentCommunityChatState extends State<ParentCommunityChat> {
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

    await DoctorChatService.addCommunity(
      "وليّ الأمر خالد",
      text,
      imagePath: imagePath,
    );
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

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg["sender"].toString().contains("وليّ الأمر");
    final color = isMe ? AppColors.pink : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (msg["sender"] != null)
              Text(
                msg["sender"],
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.8)),
              ),
            const SizedBox(
              height: 4,
            ),
            if (msg["image"] != null && msg["image"].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: kIsWeb
                    ? Image.network(msg["image"], height: 150)
                    : Image.file(File(msg["image"]), height: 150),
              ),
            if (msg["text"] != null && msg["text"].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(msg["text"], style: TextStyle(color: textColor)),
              ),
            const SizedBox(height: 4),
            Text(
              msg["time"]?.toString().substring(11, 16) ?? "",
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 11),
            ),
          ],
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
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/chat_Background.jpg"),
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
                icon: const Icon(Icons.image, color: AppColors.pink),
                onPressed: _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "اكتب رسالة...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.pink),
                onPressed: _sendMessage,
              )
            ]),
          )
        ]),
      ]),
    );
  }
}
